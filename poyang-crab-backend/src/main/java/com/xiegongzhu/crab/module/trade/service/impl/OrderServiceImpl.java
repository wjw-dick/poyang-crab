package com.xiegongzhu.crab.module.trade.service.impl;

import com.baomidou.mybatisplus.core.toolkit.IdWorker;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.xiegongzhu.crab.common.config.RabbitMQConfig;
import com.xiegongzhu.crab.common.exception.BizException;
import com.xiegongzhu.crab.common.result.ResultCode;
import com.xiegongzhu.crab.module.product.entity.Product;
import com.xiegongzhu.crab.module.product.entity.ProductSku;
import com.xiegongzhu.crab.module.product.entity.Stock;
import com.xiegongzhu.crab.module.product.entity.StockLog;
import com.xiegongzhu.crab.module.product.mapper.ProductMapper;
import com.xiegongzhu.crab.module.product.mapper.ProductSkuMapper;
import com.xiegongzhu.crab.module.product.mapper.StockLogMapper;
import com.xiegongzhu.crab.module.product.mapper.StockMapper;
import com.xiegongzhu.crab.module.system.service.SysConfigService;
import com.xiegongzhu.crab.module.trade.dto.OrderCreateRequest;
import com.xiegongzhu.crab.module.trade.entity.Order;
import com.xiegongzhu.crab.module.trade.entity.OrderDelivery;
import com.xiegongzhu.crab.module.trade.entity.OrderItem;
import com.xiegongzhu.crab.module.trade.entity.Payment;
import com.xiegongzhu.crab.module.trade.mapper.OrderDeliveryMapper;
import com.xiegongzhu.crab.module.trade.mapper.OrderItemMapper;
import com.xiegongzhu.crab.module.trade.mapper.OrderMapper;
import com.xiegongzhu.crab.module.trade.mapper.PaymentMapper;
import com.xiegongzhu.crab.module.trade.service.OrderService;
import com.xiegongzhu.crab.module.wechat.service.WxPayService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Service
public class OrderServiceImpl extends ServiceImpl<OrderMapper, Order> implements OrderService {

    private static final Logger log = LoggerFactory.getLogger(OrderServiceImpl.class);
    private static final DateTimeFormatter NO_FORMAT = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");

    private final OrderItemMapper orderItemMapper;
    private final PaymentMapper paymentMapper;
    private final OrderDeliveryMapper orderDeliveryMapper;
    private final ProductMapper productMapper;
    private final ProductSkuMapper productSkuMapper;
    private final StockMapper stockMapper;
    private final StockLogMapper stockLogMapper;
    private final SysConfigService sysConfigService;
    private final RabbitTemplate rabbitTemplate;
    private final WxPayService wxPayService;

    @Value("${crab.storage.local.domain:}")
    private String placeholderDomain;

    public OrderServiceImpl(OrderItemMapper orderItemMapper, PaymentMapper paymentMapper,
                            OrderDeliveryMapper orderDeliveryMapper, ProductMapper productMapper,
                            ProductSkuMapper productSkuMapper, StockMapper stockMapper,
                            StockLogMapper stockLogMapper, SysConfigService sysConfigService,
                            RabbitTemplate rabbitTemplate, WxPayService wxPayService) {
        this.orderItemMapper = orderItemMapper;
        this.paymentMapper = paymentMapper;
        this.orderDeliveryMapper = orderDeliveryMapper;
        this.productMapper = productMapper;
        this.productSkuMapper = productSkuMapper;
        this.stockMapper = stockMapper;
        this.stockLogMapper = stockLogMapper;
        this.sysConfigService = sysConfigService;
        this.rabbitTemplate = rabbitTemplate;
        this.wxPayService = wxPayService;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Order createOrder(OrderCreateRequest request, Long memberId) {
        boolean wholesale = "WHOLESALE".equalsIgnoreCase(request.getBizMode());
        BigDecimal freight = sysConfigService.getDecimal("business.freight.cold.chain", BigDecimal.ZERO);
        int minOrderQty = sysConfigService.getInt("business.channel.min.order.qty", 1);

        Order order = new Order();
        order.setOrderNo(generateNo("DD"));
        order.setMemberId(memberId);
        order.setBizMode(wholesale ? "WHOLESALE" : "RETAIL");
        order.setChannelId(request.getChannelId());
        order.setOrderStatus(STATUS_UNPAID);
        order.setPayStatus("UNPAID");
        order.setSource(request.getSource());
        order.setReceiverName(request.getReceiverName());
        order.setReceiverMobile(request.getReceiverMobile());
        order.setReceiverAddress(request.getReceiverAddress());
        order.setCouponId(request.getCouponId());
        order.setFreightAmount(freight);
        int expireMinutes = sysConfigService.getInt("business.order.expire.minutes", 30);
        order.setExpireTime(LocalDateTime.now().plusMinutes(expireMinutes));

        BigDecimal total = BigDecimal.ZERO;
        int totalQty = 0;
        List<OrderItem> items = new ArrayList<>();
        for (OrderCreateRequest.Item reqItem : request.getItems()) {
            ProductSku sku = productSkuMapper.selectById(reqItem.getSkuId());
            if (sku == null) {
                throw new BizException("SKU 不存在：" + reqItem.getSkuId());
            }
            Product product = productMapper.selectById(sku.getProductId());
            int qty = reqItem.getQty() == null ? 1 : reqItem.getQty();
            if (wholesale && qty < minOrderQty) {
                throw new BizException("批发起订量为 " + minOrderQty + " 件，请调整数量");
            }
            BigDecimal price = wholesale ? sku.getWholesalePrice() : sku.getRetailPrice();
            if (price == null) {
                price = BigDecimal.ZERO;
            }
            BigDecimal amount = price.multiply(BigDecimal.valueOf(qty));
            total = total.add(amount);
            totalQty += qty;

            // 自营 + 批发共用库存：锁定（available -> locked）
            lockStock(sku.getId(), qty, order.getOrderNo());

            OrderItem item = new OrderItem();
            item.setOrderNo(order.getOrderNo());
            item.setProductId(sku.getProductId());
            item.setSkuId(sku.getId());
            item.setProductName(product == null ? sku.getSkuName() : product.getProductName());
            item.setSkuName(sku.getSkuName());
            item.setPrice(price);
            item.setQty(qty);
            item.setAmount(amount);
            item.setImage(sku.getImage());
            items.add(item);
        }

        order.setTotalAmount(total);
        order.setPayAmount(total.add(freight));
        save(order);

        Long orderId = order.getId();
        for (OrderItem item : items) {
            item.setOrderId(orderId);
            orderItemMapper.insert(item);
        }

        // 延迟队列：超时未支付自动取消
        rabbitTemplate.convertAndSend(RabbitMQConfig.DELAY_EXCHANGE, RabbitMQConfig.DELAY_KEY,
                order.getOrderNo(), message -> {
                    message.getMessageProperties().setExpiration(String.valueOf(expireMinutes * 60L * 1000L));
                    return message;
                });
        log.info("下单成功 orderNo={} 金额={} 件数={}", order.getOrderNo(), order.getPayAmount(), totalQty);
        return order;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Map<String, String> createPayment(String orderNo, String payType, String openId) {
        Order order = getByOrderNo(orderNo);
        if (!STATUS_UNPAID.equals(order.getOrderStatus())) {
            throw new BizException(ResultCode.ORDER_STATUS_ERROR, "订单状态不允许支付");
        }
        Payment payment = new Payment();
        payment.setPayNo(generateNo("PAY"));
        payment.setOrderNo(orderNo);
        payment.setPayType(payType);
        payment.setAmount(order.getPayAmount());
        payment.setPayStatus("UNPAID");
        paymentMapper.insert(payment);

        if (!"WECHAT".equalsIgnoreCase(payType)) {
            return Map.of("payNo", payment.getPayNo(), "payType", payType);
        }
        long fen = order.getPayAmount().multiply(BigDecimal.valueOf(100)).longValue();
        return wxPayService.jsapiPay(payment.getPayNo(), openId, fen, "鄱阳湖湖蟹-鲜活冷链");
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void markPaid(String payNo, String tradeNo, String payType) {
        Payment payment = paymentMapper.selectOne(Wrappers.<Payment>lambdaQuery()
                .eq(Payment::getPayNo, payNo));
        if (payment == null) {
            throw new BizException("支付单不存在：" + payNo);
        }
        if ("SUCCESS".equals(payment.getPayStatus())) {
            return;
        }
        payment.setPayStatus("SUCCESS");
        payment.setPayType(payType);
        payment.setTradeNo(tradeNo);
        payment.setPayTime(LocalDateTime.now());
        paymentMapper.updateById(payment);

        update(Wrappers.<Order>lambdaUpdate()
                .eq(Order::getOrderNo, payment.getOrderNo())
                .eq(Order::getOrderStatus, STATUS_UNPAID)
                .set(Order::getOrderStatus, STATUS_PAID)
                .set(Order::getPayStatus, "PAID")
                .set(Order::getPayType, payType)
                .set(Order::getPayTime, LocalDateTime.now()));

        // 通知冷链发货端：新订单待分拣
        rabbitTemplate.convertAndSend(RabbitMQConfig.ORDER_EXCHANGE, RabbitMQConfig.LOGISTICS_KEY,
                Map.of("orderNo", payment.getOrderNo(), "shipStatus", "WAIT"));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void cancelExpired(String orderNo) {
        Order order = getByOrderNo(orderNo);
        if (!STATUS_UNPAID.equals(order.getOrderStatus())) {
            return;
        }
        update(Wrappers.<Order>lambdaUpdate()
                .eq(Order::getOrderNo, orderNo)
                .eq(Order::getOrderStatus, STATUS_UNPAID)
                .set(Order::getOrderStatus, STATUS_CANCELLED)
                .set(Order::getCancelReason, "超时未支付自动取消"));

        List<OrderItem> items = orderItemMapper.selectList(Wrappers.<OrderItem>lambdaQuery()
                .eq(OrderItem::getOrderNo, orderNo));
        for (OrderItem item : items) {
            releaseStock(item.getSkuId(), item.getQty(), orderNo);
        }
        log.info("订单超时取消 orderNo={}", orderNo);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void ship(String orderNo, String expressNo, String packCheck, Long packerId) {
        Order order = getByOrderNo(orderNo);
        if (!STATUS_PAID.equals(order.getOrderStatus()) && !STATUS_SORTING.equals(order.getOrderStatus())
                && !STATUS_PACKED.equals(order.getOrderStatus())) {
            throw new BizException(ResultCode.ORDER_STATUS_ERROR, "只有已支付订单可以发货");
        }
        List<OrderItem> items = orderItemMapper.selectList(Wrappers.<OrderItem>lambdaQuery()
                .eq(OrderItem::getOrderNo, orderNo));

        OrderDelivery delivery = orderDeliveryMapper.selectOne(Wrappers.<OrderDelivery>lambdaQuery()
                .eq(OrderDelivery::getOrderNo, orderNo));
        if (delivery == null) {
            delivery = new OrderDelivery();
            delivery.setOrderNo(orderNo);
            delivery.setExpressCompany("SF");
            delivery.setColdChain(1);
            delivery.setExpressNo(expressNo);
            delivery.setPackCheck(packCheck);
            delivery.setPackerId(packerId);
            delivery.setShipStatus("SHIPPED");
            delivery.setExpressPrintTime(LocalDateTime.now());
            delivery.setOutboundTime(LocalDateTime.now());
            delivery.setShipTime(LocalDateTime.now());
            orderDeliveryMapper.insert(delivery);
        } else {
            delivery.setExpressNo(expressNo);
            delivery.setPackCheck(packCheck);
            delivery.setPackerId(packerId);
            delivery.setShipStatus("SHIPPED");
            delivery.setShipTime(LocalDateTime.now());
            orderDeliveryMapper.updateById(delivery);
        }

        // 出库：锁定库存核销，总库存扣减（自营 + 批发共用）
        for (OrderItem item : items) {
            stockMapper.update(null, Wrappers.<Stock>lambdaUpdate()
                    .eq(Stock::getSkuId, item.getSkuId())
                    .setSql("locked_qty = GREATEST(locked_qty - " + item.getQty() + ", 0)")
                    .setSql("total_qty = GREATEST(total_qty - " + item.getQty() + ", 0)"));
            StockLog stockLog = new StockLog();
            stockLog.setSkuId(item.getSkuId());
            stockLog.setChangeType("OUT");
            stockLog.setQty(item.getQty());
            stockLog.setBizType("SHIP");
            stockLog.setBizNo(orderNo);
            stockLogMapper.insert(stockLog);
        }

        update(Wrappers.<Order>lambdaUpdate()
                .eq(Order::getOrderNo, orderNo)
                .set(Order::getOrderStatus, STATUS_SHIPPED));

        rabbitTemplate.convertAndSend(RabbitMQConfig.ORDER_EXCHANGE, RabbitMQConfig.LOGISTICS_KEY,
                Map.of("orderNo", orderNo, "expressNo", expressNo, "shipStatus", "SHIPPED"));
    }

    @Override
    public void confirmReceive(String orderNo) {
        update(Wrappers.<Order>lambdaUpdate()
                .eq(Order::getOrderNo, orderNo)
                .eq(Order::getOrderStatus, STATUS_SHIPPED)
                .set(Order::getOrderStatus, STATUS_RECEIVED));
        orderDeliveryMapper.update(null, Wrappers.<OrderDelivery>lambdaUpdate()
                .eq(OrderDelivery::getOrderNo, orderNo)
                .set(OrderDelivery::getShipStatus, "SIGNED")
                .set(OrderDelivery::getSignedTime, LocalDateTime.now()));
    }

    private Order getByOrderNo(String orderNo) {
        Order order = getOne(Wrappers.<Order>lambdaQuery().eq(Order::getOrderNo, orderNo));
        if (order == null) {
            throw new BizException(ResultCode.NOT_FOUND, "订单不存在：" + orderNo);
        }
        return order;
    }

    private void lockStock(Long skuId, int qty, String orderNo) {
        int rows = stockMapper.update(null, Wrappers.<Stock>lambdaUpdate()
                .eq(Stock::getSkuId, skuId)
                .ge(Stock::getAvailableQty, qty)
                .setSql("available_qty = available_qty - " + qty)
                .setSql("locked_qty = locked_qty + " + qty));
        if (rows == 0) {
            throw new BizException(ResultCode.STOCK_NOT_ENOUGH, "库存不足，请减少数量或等待补货");
        }
        StockLog stockLog = new StockLog();
        stockLog.setSkuId(skuId);
        stockLog.setChangeType("LOCK");
        stockLog.setQty(qty);
        stockLog.setBizType("ORDER");
        stockLog.setBizNo(orderNo);
        stockLogMapper.insert(stockLog);
    }

    private void releaseStock(Long skuId, int qty, String orderNo) {
        stockMapper.update(null, Wrappers.<Stock>lambdaUpdate()
                .eq(Stock::getSkuId, skuId)
                .setSql("available_qty = available_qty + " + qty)
                .setSql("locked_qty = GREATEST(locked_qty - " + qty + ", 0)"));
        StockLog stockLog = new StockLog();
        stockLog.setSkuId(skuId);
        stockLog.setChangeType("UNLOCK");
        stockLog.setQty(qty);
        stockLog.setBizType("CANCEL");
        stockLog.setBizNo(orderNo);
        stockLogMapper.insert(stockLog);
    }

    private String generateNo(String prefix) {
        return prefix + LocalDateTime.now().format(NO_FORMAT) + IdWorker.getIdStr().substring(10);
    }
}
