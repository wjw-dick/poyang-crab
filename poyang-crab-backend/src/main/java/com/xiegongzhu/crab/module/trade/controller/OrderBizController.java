package com.xiegongzhu.crab.module.trade.controller;

import com.xiegongzhu.crab.common.annotation.AuditLog;
import com.xiegongzhu.crab.common.annotation.RateLimit;
import com.xiegongzhu.crab.common.result.R;
import com.xiegongzhu.crab.common.security.CurrentUserHolder;
import com.xiegongzhu.crab.module.trade.dto.OrderCreateRequest;
import com.xiegongzhu.crab.module.trade.entity.Order;
import com.xiegongzhu.crab.module.trade.service.OrderService;
import com.xiegongzhu.crab.module.trade.service.impl.OrderServiceImpl;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/**
 * T20/T24/T29 交易主流程接口（与通用 CRUD 控制器分离，避免语义混淆）
 * 下单 → 支付 → 冷链发货 → 确认收货
 */
@RestController
@RequestMapping("/order")
public class OrderBizController {

    private final OrderService orderService;

    public OrderBizController(OrderServiceImpl orderService) {
        this.orderService = orderService;
    }

    /** 下单（防重：同一用户 10 秒内仅允许一次） */
    @RateLimit(limit = 30, seconds = 60, dimension = "USER", key = "order:create", dedup = true)
    @AuditLog(module = "订单", operation = "CREATE")
    @PostMapping("/create")
    public R<Order> create(@Valid @RequestBody OrderCreateRequest request) {
        return R.ok(orderService.createOrder(request, CurrentUserHolder.userId()));
    }

    /** 发起支付，返回小程序 wx.requestPayment 参数 */
    @RateLimit(limit = 30, seconds = 60, dimension = "USER", key = "order:pay")
    @AuditLog(module = "订单", operation = "UPDATE")
    @PostMapping("/pay")
    public R<Map<String, String>> pay(@RequestParam String orderNo,
                                      @RequestParam(defaultValue = "WECHAT") String payType,
                                      @RequestParam(required = false) String openId) {
        return R.ok(orderService.createPayment(orderNo, payType, openId));
    }

    /** 冷链发货（发货端回填运单号 + 鲜活打包核验） */
    @AuditLog(module = "冷链发货", operation = "UPDATE")
    @PostMapping("/ship")
    public R<Void> ship(@RequestParam String orderNo,
                        @RequestParam String expressNo,
                        @RequestParam(required = false) String packCheck) {
        orderService.ship(orderNo, expressNo, packCheck, CurrentUserHolder.userId());
        return R.ok();
    }

    /** 确认收货（触发评价入口） */
    @AuditLog(module = "订单", operation = "UPDATE")
    @PostMapping("/confirm")
    public R<Void> confirm(@RequestParam String orderNo) {
        orderService.confirmReceive(orderNo);
        return R.ok();
    }

    /** 手动取消（超时取消由延迟队列自动完成） */
    @AuditLog(module = "订单", operation = "UPDATE")
    @PostMapping("/cancel")
    public R<Void> cancel(@RequestParam String orderNo) {
        orderService.cancelExpired(orderNo);
        return R.ok();
    }
}
