package com.xiegongzhu.crab.module.trade.controller;

import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.xiegongzhu.crab.common.exception.BizException;
import com.xiegongzhu.crab.common.result.PageResult;
import com.xiegongzhu.crab.common.result.R;
import com.xiegongzhu.crab.common.security.CurrentUserHolder;
import com.xiegongzhu.crab.module.trade.entity.Order;
import com.xiegongzhu.crab.module.trade.entity.OrderDelivery;
import com.xiegongzhu.crab.module.trade.entity.OrderItem;
import com.xiegongzhu.crab.module.trade.mapper.OrderDeliveryMapper;
import com.xiegongzhu.crab.module.trade.mapper.OrderItemMapper;
import com.xiegongzhu.crab.module.trade.mapper.OrderMapper;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * T24 「我的订单」只读查询（小程序 / H5 共用）。
 *
 * 与 {@link OrderBizController} 区分：
 * - OrderBizController 负责下单 / 支付 / 发货 / 收货等写操作；
 * - 本控制器只做归属校验后的读操作，避免 BaseCrudController 的通用 /page 越权读取他人订单。
 *
 * 渠道商端（CHANNEL）按 channelId 口径过滤，会员端（MEMBER）按 memberId 口径过滤。
 */
@RestController
@RequestMapping("/order/my")
public class OrderQueryController {

    private final OrderMapper orderMapper;
    private final OrderItemMapper orderItemMapper;
    private final OrderDeliveryMapper orderDeliveryMapper;

    public OrderQueryController(OrderMapper orderMapper, OrderItemMapper orderItemMapper,
                                OrderDeliveryMapper orderDeliveryMapper) {
        this.orderMapper = orderMapper;
        this.orderItemMapper = orderItemMapper;
        this.orderDeliveryMapper = orderDeliveryMapper;
    }

    /** 我的订单分页：支持状态筛选与批发/零售筛选 */
    @GetMapping("/page")
    public R<PageResult<Order>> page(@RequestParam(defaultValue = "1") long current,
                                     @RequestParam(defaultValue = "10") long size,
                                     @RequestParam(required = false) String status,
                                     @RequestParam(required = false) String bizMode) {
        Long channelId = CurrentUserHolder.channelId();
        boolean channelSide = channelId != null && channelId > 0;
        return R.ok(PageResult.of(orderMapper.selectPage(new Page<>(current, size),
                Wrappers.<Order>lambdaQuery()
                        .eq(channelSide, Order::getChannelId, channelId)
                        .eq(!channelSide, Order::getMemberId, CurrentUserHolder.userId())
                        .eq(status != null && !status.isBlank(), Order::getOrderStatus, status)
                        .eq(bizMode != null && !bizMode.isBlank(), Order::getBizMode, bizMode)
                        .orderByDesc(Order::getCreateTime))));
    }

    /** 订单详情（按订单号，校验归属，避免越权查看） */
    @GetMapping("/by-no/{orderNo}")
    public R<Order> byNo(@PathVariable String orderNo) {
        Order order = orderMapper.selectOne(Wrappers.<Order>lambdaQuery().eq(Order::getOrderNo, orderNo));
        if (order == null) {
            throw new BizException("订单不存在：" + orderNo);
        }
        assertOwner(order);
        return R.ok(order);
    }

    /** 订单明细 */
    @GetMapping("/items")
    public R<List<OrderItem>> items(@RequestParam Long orderId) {
        Order order = orderMapper.selectById(orderId);
        if (order == null) {
            throw new BizException("订单不存在");
        }
        assertOwner(order);
        return R.ok(orderItemMapper.selectList(Wrappers.<OrderItem>lambdaQuery()
                .eq(OrderItem::getOrderId, orderId)));
    }

    /** 冷链物流信息（含顺丰轨迹缓存） */
    @GetMapping("/delivery")
    public R<OrderDelivery> delivery(@RequestParam Long orderId) {
        Order order = orderMapper.selectById(orderId);
        if (order == null) {
            throw new BizException("订单不存在");
        }
        assertOwner(order);
        return R.ok(orderDeliveryMapper.selectOne(Wrappers.<OrderDelivery>lambdaQuery()
                .eq(OrderDelivery::getOrderNo, order.getOrderNo())
                .orderByDesc(OrderDelivery::getCreateTime)
                .last("LIMIT 1")));
    }

    /** 归属校验：会员只能看自己的订单，渠道商只能看自己渠道的订单 */
    private void assertOwner(Order order) {
        Long channelId = CurrentUserHolder.channelId();
        if (channelId != null && channelId > 0) {
            if (!channelId.equals(order.getChannelId())) {
                throw new BizException("无权查看该订单");
            }
            return;
        }
        if (!CurrentUserHolder.isAdmin() && !CurrentUserHolder.userId().equals(order.getMemberId())) {
            throw new BizException("无权查看该订单");
        }
    }
}
