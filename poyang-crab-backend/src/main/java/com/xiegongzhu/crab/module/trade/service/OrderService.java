package com.xiegongzhu.crab.module.trade.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.xiegongzhu.crab.module.trade.dto.OrderCreateRequest;
import com.xiegongzhu.crab.module.trade.entity.Order;

import java.util.Map;

/**
 * 核心交易：全款在线下单 → 微信支付 → 冷链发货 → 物流 → 评价
 */
public interface OrderService extends IService<Order> {

    String STATUS_UNPAID = "UNPAID";
    String STATUS_PAID = "PAID";
    String STATUS_SORTING = "SORTING";
    String STATUS_PACKED = "PACKED";
    String STATUS_SHIPPED = "SHIPPED";
    String STATUS_RECEIVED = "RECEIVED";
    String STATUS_COMPLETED = "COMPLETED";
    String STATUS_CANCELLED = "CANCELLED";

    /** 下单：校验库存并锁定（自营 + 批发共用库存），同时投递延迟消息用于超时取消 */
    Order createOrder(OrderCreateRequest request, Long memberId);

    /** 创建支付单（微信 JSAPI / 储值余额），返回小程序 wx.requestPayment 参数 */
    Map<String, String> createPayment(String orderNo, String payType, String openId);

    /** 支付成功落库（由支付回调解耦后的消费者调用） */
    void markPaid(String payNo, String tradeNo, String payType);

    /** 超时未支付自动取消（延迟队列消费），并释放锁定库存 */
    void cancelExpired(String orderNo);

    /** 冷链发货：回填运单号并扣减库存（锁定库存转出库） */
    void ship(String orderNo, String expressNo, String packCheck, Long packerId);

    /** 确认收货 */
    void confirmReceive(String orderNo);
}
