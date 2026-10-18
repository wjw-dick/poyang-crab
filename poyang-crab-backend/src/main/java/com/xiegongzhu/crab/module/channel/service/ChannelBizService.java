package com.xiegongzhu.crab.module.channel.service;

import com.baomidou.mybatisplus.core.toolkit.IdWorker;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.xiegongzhu.crab.common.exception.BizException;
import com.xiegongzhu.crab.common.result.PageResult;
import com.xiegongzhu.crab.module.channel.entity.Channel;
import com.xiegongzhu.crab.module.channel.entity.ChannelOrder;
import com.xiegongzhu.crab.module.channel.entity.ChannelOrderItem;
import com.xiegongzhu.crab.module.channel.entity.ChannelQuotaLog;
import com.xiegongzhu.crab.module.channel.entity.Commission;
import com.xiegongzhu.crab.module.channel.entity.Settlement;
import com.xiegongzhu.crab.module.channel.mapper.ChannelMapper;
import com.xiegongzhu.crab.module.channel.mapper.ChannelOrderItemMapper;
import com.xiegongzhu.crab.module.channel.mapper.ChannelOrderMapper;
import com.xiegongzhu.crab.module.channel.mapper.ChannelQuotaLogMapper;
import com.xiegongzhu.crab.module.channel.mapper.CommissionMapper;
import com.xiegongzhu.crab.module.channel.mapper.SettlementMapper;
import com.xiegongzhu.crab.module.product.entity.Product;
import com.xiegongzhu.crab.module.product.entity.ProductSku;
import com.xiegongzhu.crab.module.product.mapper.ProductMapper;
import com.xiegongzhu.crab.module.product.mapper.ProductSkuMapper;
import com.xiegongzhu.crab.module.system.service.SysConfigService;
import com.xiegongzhu.crab.module.trade.dto.OrderCreateRequest;
import com.xiegongzhu.crab.module.trade.entity.Order;
import com.xiegongzhu.crab.module.trade.service.OrderService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * T25-T27 渠道商：报单 / 渠道专属价 / 佣金与转介绍返佣 / 额度 / 对账 / 结算
 * 所有比例均来自 sys_config（后台可配置），落库时快照 rate 便于审计留痕。
 */
@Service
public class ChannelBizService {

    private static final Logger log = LoggerFactory.getLogger(ChannelBizService.class);

    private final ChannelMapper channelMapper;
    private final ChannelOrderMapper channelOrderMapper;
    private final ChannelOrderItemMapper channelOrderItemMapper;
    private final CommissionMapper commissionMapper;
    private final SettlementMapper settlementMapper;
    private final ProductSkuMapper productSkuMapper;
    private final ProductMapper productMapper;
    private final ChannelQuotaLogMapper channelQuotaLogMapper;
    private final OrderService orderService;
    private final SysConfigService sysConfigService;

    public ChannelBizService(ChannelMapper channelMapper, ChannelOrderMapper channelOrderMapper,
                             ChannelOrderItemMapper channelOrderItemMapper, CommissionMapper commissionMapper,
                             SettlementMapper settlementMapper, ProductSkuMapper productSkuMapper,
                             ProductMapper productMapper, ChannelQuotaLogMapper channelQuotaLogMapper,
                             OrderService orderService, SysConfigService sysConfigService) {
        this.channelMapper = channelMapper;
        this.channelOrderMapper = channelOrderMapper;
        this.channelOrderItemMapper = channelOrderItemMapper;
        this.commissionMapper = commissionMapper;
        this.settlementMapper = settlementMapper;
        this.productSkuMapper = productSkuMapper;
        this.productMapper = productMapper;
        this.channelQuotaLogMapper = channelQuotaLogMapper;
        this.orderService = orderService;
        this.sysConfigService = sysConfigService;
    }

    /** 渠道商报单：按渠道专属价计算，等待后台审核 */
    @Transactional(rollbackFor = Exception.class)
    public ChannelOrder submitReport(Long channelId, List<OrderCreateRequest.Item> items) {
        Channel channel = requireChannel(channelId);
        if (!"NORMAL".equals(channel.getStatus())) {
            throw new BizException("渠道商状态非正常，无法报单（当前：" + channel.getStatus() + "）");
        }
        int minOrderQty = sysConfigService.getInt("business.channel.min.order.qty", 10);

        ChannelOrder report = new ChannelOrder();
        report.setReportNo("BD" + IdWorker.getIdStr());
        report.setChannelId(channelId);
        report.setAuditStatus("PENDING");
        report.setTotalQty(0);
        report.setTotalAmount(BigDecimal.ZERO);
        channelOrderMapper.insert(report);

        int totalQty = 0;
        BigDecimal totalAmount = BigDecimal.ZERO;
        List<ChannelOrderItem> details = new ArrayList<>();
        for (OrderCreateRequest.Item reqItem : items) {
            ProductSku sku = productSkuMapper.selectById(reqItem.getSkuId());
            if (sku == null) {
                throw new BizException("SKU 不存在：" + reqItem.getSkuId());
            }
            BigDecimal price = channelPrice(sku);
            int qty = reqItem.getQty() == null ? 0 : reqItem.getQty();
            BigDecimal amount = price.multiply(BigDecimal.valueOf(qty));
            totalQty += qty;
            totalAmount = totalAmount.add(amount);

            ChannelOrderItem detail = new ChannelOrderItem();
            detail.setReportNo(report.getReportNo());
            detail.setChannelId(channelId);
            detail.setProductId(sku.getProductId());
            detail.setSkuId(sku.getId());
            detail.setSkuName(sku.getSkuName());
            detail.setChannelPrice(price);
            detail.setQty(qty);
            detail.setAmount(amount);
            details.add(detail);
        }
        if (totalQty < minOrderQty) {
            throw new BizException("批发起订量为 " + minOrderQty + " 件，当前 " + totalQty + " 件");
        }
        report.setTotalQty(totalQty);
        report.setTotalAmount(totalAmount);
        channelOrderMapper.updateById(report);
        for (ChannelOrderItem detail : details) {
            channelOrderItemMapper.insert(detail);
        }
        return report;
    }

    /** 报单审核：通过后转为正式批发订单（共用库存与订单体系） */
    @Transactional(rollbackFor = Exception.class)
    public String auditReport(String reportNo, boolean approved, String remark, Long auditorId) {
        ChannelOrder report = channelOrderMapper.selectOne(Wrappers.<ChannelOrder>lambdaQuery()
                .eq(ChannelOrder::getReportNo, reportNo));
        if (report == null) {
            throw new BizException("报单不存在：" + reportNo);
        }
        if (!"PENDING".equals(report.getAuditStatus())) {
            throw new BizException("报单已审核，请勿重复操作");
        }
        report.setAuditStatus(approved ? "APPROVED" : "REJECTED");
        report.setAuditBy(auditorId);
        report.setAuditTime(LocalDateTime.now());
        report.setAuditRemark(remark);

        String orderNo = null;
        if (approved) {
            List<ChannelOrderItem> details = channelOrderItemMapper.selectList(
                    Wrappers.<ChannelOrderItem>lambdaQuery().eq(ChannelOrderItem::getReportNo, reportNo));
            OrderCreateRequest request = new OrderCreateRequest();
            request.setBizMode("WHOLESALE");
            request.setChannelId(report.getChannelId());
            request.setSource("CHANNEL");
            request.setItems(details.stream().map(detail -> {
                OrderCreateRequest.Item item = new OrderCreateRequest.Item();
                item.setSkuId(detail.getSkuId());
                item.setQty(detail.getQty());
                return item;
            }).toList());
            Order order = orderService.createOrder(request, report.getChannelId());
            orderNo = order.getOrderNo();
            report.setOrderNo(orderNo);
        }
        channelOrderMapper.updateById(report);
        return orderNo;
    }

    /**
     * 佣金 / 转介绍返佣计算（订单支付后调用）
     * 比例取渠道档案配置，为空则回退系统默认值，并快照到佣金记录。
     */
    @Transactional(rollbackFor = Exception.class)
    public void calculateCommission(Long channelId, String orderNo, BigDecimal baseAmount) {
        Channel channel = requireChannel(channelId);
        BigDecimal rate = channel.getCommissionRate();
        if (rate == null || rate.compareTo(BigDecimal.ZERO) == 0) {
            rate = sysConfigService.getDecimal("business.channel.default.commission.rate", BigDecimal.ZERO);
        }
        saveCommission(channel, channelId, null, orderNo, "DISTRIBUTION", baseAmount, rate);
        if (channel.getParentId() != null && channel.getParentId() > 0) {
            Channel parent = channelMapper.selectById(channel.getParentId());
            if (parent != null) {
                BigDecimal referralRate = parent.getReferralRate();
                if (referralRate == null || referralRate.compareTo(BigDecimal.ZERO) == 0) {
                    referralRate = sysConfigService.getDecimal("business.channel.default.referral.rate", BigDecimal.ZERO);
                }
                saveCommission(parent, parent.getId(), channelId, orderNo, "REFERRAL", baseAmount, referralRate);
            }
        }
    }

    /** 生成对账结算单（DRAFT），确认后进入待打款 */
    @Transactional(rollbackFor = Exception.class)
    public Settlement createSettlement(Long channelId, LocalDate start, LocalDate end) {
        requireChannel(channelId);
        List<Commission> commissions = commissionMapper.selectList(Wrappers.<Commission>lambdaQuery()
                .eq(Commission::getChannelId, channelId)
                .eq(Commission::getSettleStatus, "PENDING"));
        BigDecimal commissionAmount = commissions.stream()
                .map(Commission::getAmount)
                .filter(amount -> amount != null)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        Settlement settlement = new Settlement();
        settlement.setSettleNo("JS" + IdWorker.getIdStr());
        settlement.setChannelId(channelId);
        settlement.setPeriodStart(start);
        settlement.setPeriodEnd(end);
        settlement.setOrderAmount(commissionAmount);
        settlement.setCommissionAmount(commissionAmount);
        settlement.setSettleAmount(commissionAmount);
        settlement.setStatus("DRAFT");
        settlementMapper.insert(settlement);
        return settlement;
    }

    /** 结算确认：佣金标记为已结算，金额与后台数据一致（T30 核对口径） */
    @Transactional(rollbackFor = Exception.class)
    public void confirmSettlement(String settleNo) {
        confirmSettlement(settleNo, null);
    }

    /**
     * 结算确认。
     *
     * @param ownerChannelId 非空时校验结算单归属该渠道商（渠道商自助确认场景）
     */
    @Transactional(rollbackFor = Exception.class)
    public void confirmSettlement(String settleNo, Long ownerChannelId) {
        Settlement settlement = settlementMapper.selectOne(Wrappers.<Settlement>lambdaQuery()
                .eq(Settlement::getSettleNo, settleNo));
        if (settlement == null) {
            throw new BizException("结算单不存在：" + settleNo);
        }
        if (ownerChannelId != null && !ownerChannelId.equals(settlement.getChannelId())) {
            throw new BizException("无权操作他人结算单");
        }
        if (!"DRAFT".equals(settlement.getStatus())) {
            throw new BizException("结算单已确认，请勿重复操作");
        }
        settlement.setStatus("CONFIRMED");
        settlement.setConfirmTime(LocalDateTime.now());
        settlementMapper.updateById(settlement);
        commissionMapper.update(null, Wrappers.<Commission>lambdaUpdate()
                .eq(Commission::getChannelId, settlement.getChannelId())
                .eq(Commission::getSettleStatus, "PENDING")
                .set(Commission::getSettleStatus, "SETTLED")
                .set(Commission::getSettleNo, settleNo));
        log.info("结算单确认 settleNo={} 金额={}", settleNo, settlement.getSettleAmount());
    }

    /**
     * T27 渠道商自助概览：渠道档案 + 额度占用 + 待结算佣金 + 待确认结算单数。
     * 供渠道商端小程序「工作台」直接渲染，避免前端多次聚合请求。
     */
    public Map<String, Object> overview(Long channelId) {
        Channel channel = profile(channelId);
        BigDecimal pendingCommission = commissionMapper
                .selectList(Wrappers.<Commission>lambdaQuery()
                        .eq(Commission::getChannelId, channelId)
                        .eq(Commission::getSettleStatus, "PENDING"))
                .stream()
                .map(Commission::getAmount)
                .filter(amount -> amount != null)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        Long draftSettlementCount = settlementMapper.selectCount(Wrappers.<Settlement>lambdaQuery()
                .eq(Settlement::getChannelId, channelId)
                .eq(Settlement::getStatus, "DRAFT"));

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("channel", channel);
        data.put("creditQuota", channel.getCreditQuota());
        data.put("usedQuota", channel.getUsedQuota());
        data.put("availableQuota", channel.getCreditQuota() == null ? null
                : channel.getCreditQuota().subtract(channel.getUsedQuota() == null ? BigDecimal.ZERO : channel.getUsedQuota()));
        data.put("commissionRate", channel.getCommissionRate());
        data.put("referralRate", channel.getReferralRate());
        data.put("pendingCommission", pendingCommission);
        data.put("draftSettlementCount", draftSettlementCount);
        data.put("childCount", channelMapper.selectCount(Wrappers.<Channel>lambdaQuery()
                .eq(Channel::getParentId, channelId)));
        data.put("minOrderQty", sysConfigService.getInt("business.channel.min.order.qty", 10));
        data.put("defaultCommissionRate", sysConfigService.getDecimal("business.channel.default.commission.rate", BigDecimal.ZERO));
        data.put("defaultReferralRate", sysConfigService.getDecimal("business.channel.default.referral.rate", BigDecimal.ZERO));
        return data;
    }

    /** 渠道商档案查询（渠道端登录后拉取自身信息，脱敏 unionId / 证照图片） */
    public Channel profile(Long channelId) {
        Channel channel = requireChannel(channelId);
        channel.setUnionId(null);
        channel.setLicenseImages(null);
        return channel;
    }

    /** 渠道商额度流水（按时间倒序） */
    public List<ChannelQuotaLog> quotaLogs(Long channelId) {
        requireChannel(channelId);
        return channelQuotaLogMapper.selectList(Wrappers.<ChannelQuotaLog>lambdaQuery()
                .eq(ChannelQuotaLog::getChannelId, channelId)
                .orderByDesc(ChannelQuotaLog::getCreateTime));
    }

    /** 渠道商自己的报单分页（审核状态可选） */
    public PageResult<ChannelOrder> reportPage(Long channelId, long current, long size, String auditStatus) {
        requireChannel(channelId);
        return PageResult.of(channelOrderMapper.selectPage(new Page<>(current, size),
                Wrappers.<ChannelOrder>lambdaQuery()
                        .eq(ChannelOrder::getChannelId, channelId)
                        .eq(auditStatus != null && !auditStatus.isBlank(), ChannelOrder::getAuditStatus, auditStatus)
                        .orderByDesc(ChannelOrder::getCreateTime)));
    }

    /** 渠道商佣金分页（结算状态可选） */
    public PageResult<Commission> commissionPage(Long channelId, long current, long size, String settleStatus) {
        requireChannel(channelId);
        return PageResult.of(commissionMapper.selectPage(new Page<>(current, size),
                Wrappers.<Commission>lambdaQuery()
                        .eq(Commission::getChannelId, channelId)
                        .eq(settleStatus != null && !settleStatus.isBlank(), Commission::getSettleStatus, settleStatus)
                        .orderByDesc(Commission::getCreateTime)));
    }

    /** 渠道商结算单分页 */
    public PageResult<Settlement> settlementPage(Long channelId, long current, long size) {
        requireChannel(channelId);
        return PageResult.of(settlementMapper.selectPage(new Page<>(current, size),
                Wrappers.<Settlement>lambdaQuery()
                        .eq(Settlement::getChannelId, channelId)
                        .orderByDesc(Settlement::getCreateTime)));
    }

    /** 下级经销商列表（按 parent_id 反查，脱敏 unionId / 证照图片） */
    public List<Channel> dealers(Long channelId) {
        requireChannel(channelId);
        List<Channel> dealers = channelMapper.selectList(Wrappers.<Channel>lambdaQuery()
                .eq(Channel::getParentId, channelId)
                .orderByDesc(Channel::getCreateTime));
        dealers.forEach(dealer -> {
            dealer.setUnionId(null);
            dealer.setLicenseImages(null);
        });
        return dealers;
    }

    /**
     * T26 渠道商专属价商品列表：仅返回批发可售（WHOLESALE / BOTH）在架商品的 SKU 批发价。
     * 批发价为空时回退零售价，与下单时的取价口径保持一致。
     */
    public List<Map<String, Object>> channelProducts(String keyword) {
        List<Product> products = productMapper.selectList(Wrappers.<Product>lambdaQuery()
                .eq(Product::getStatus, 1)
                .in(Product::getSellMode, List.of("WHOLESALE", "BOTH"))
                .like(keyword != null && !keyword.isBlank(), Product::getProductName, keyword)
                .orderByAsc(Product::getSort));
        List<Map<String, Object>> result = new ArrayList<>();
        for (Product product : products) {
            List<ProductSku> skus = productSkuMapper.selectList(Wrappers.<ProductSku>lambdaQuery()
                    .eq(ProductSku::getProductId, product.getId())
                    .eq(ProductSku::getStatus, 1));
            List<Map<String, Object>> skuViews = new ArrayList<>();
            for (ProductSku sku : skus) {
                Map<String, Object> view = new LinkedHashMap<>();
                view.put("skuId", sku.getId());
                view.put("skuName", sku.getSkuName());
                view.put("image", sku.getImage());
                view.put("retailPrice", sku.getRetailPrice());
                view.put("channelPrice", channelPrice(sku));
                skuViews.add(view);
            }
            Map<String, Object> view = new LinkedHashMap<>();
            view.put("productId", product.getId());
            view.put("productName", product.getProductName());
            view.put("mainImage", product.getMainImage());
            view.put("origin", product.getOrigin());
            view.put("minOrderQty", product.getMinOrderQty());
            view.put("skus", skuViews);
            result.add(view);
        }
        return result;
    }

    private void saveCommission(Channel channel, Long channelId, Long fromChannelId, String orderNo,
                                String type, BigDecimal baseAmount, BigDecimal rate) {
        if (rate == null || rate.compareTo(BigDecimal.ZERO) <= 0) {
            return;
        }
        Commission commission = new Commission();
        commission.setCommissionNo("YJ" + IdWorker.getIdStr());
        commission.setChannelId(channelId);
        commission.setFromChannelId(fromChannelId);
        commission.setOrderNo(orderNo);
        commission.setCommissionType(type);
        commission.setBaseAmount(baseAmount);
        commission.setRate(rate);
        commission.setAmount(baseAmount.multiply(rate)
                .divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP));
        commission.setSettleStatus("PENDING");
        commissionMapper.insert(commission);
    }

    private BigDecimal channelPrice(ProductSku sku) {
        BigDecimal price = sku.getWholesalePrice();
        if (price == null || price.compareTo(BigDecimal.ZERO) == 0) {
            price = sku.getRetailPrice();
        }
        return price == null ? BigDecimal.ZERO : price;
    }

    private Channel requireChannel(Long channelId) {
        Channel channel = channelMapper.selectById(channelId);
        if (channel == null) {
            throw new BizException("渠道商不存在：" + channelId);
        }
        return channel;
    }
}
