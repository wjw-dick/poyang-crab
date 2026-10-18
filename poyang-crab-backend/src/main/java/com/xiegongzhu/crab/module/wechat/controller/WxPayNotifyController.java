package com.xiegongzhu.crab.module.wechat.controller;

import com.xiegongzhu.crab.common.result.R;
import com.xiegongzhu.crab.module.mq.producer.OrderMessageProducer;
import com.xiegongzhu.crab.module.wechat.service.WxPayService;
import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;

/**
 * T20 微信支付回调入口：验签后仅做「解耦投递」，业务落库由 PayNotifyConsumer 完成
 * 白名单路径：/pay/notify/**（WebMvcConfig 已排除登录拦截）
 */
@RestController
@RequestMapping("/pay/notify")
public class WxPayNotifyController {

    private static final Logger log = LoggerFactory.getLogger(WxPayNotifyController.class);

    private final WxPayService wxPayService;
    private final OrderMessageProducer orderMessageProducer;

    public WxPayNotifyController(WxPayService wxPayService, OrderMessageProducer orderMessageProducer) {
        this.wxPayService = wxPayService;
        this.orderMessageProducer = orderMessageProducer;
    }

    @PostMapping("/wechat")
    public Map<String, String> wechatNotify(@RequestBody String body, HttpServletRequest request) {
        Map<String, String> headers = new HashMap<>();
        Enumeration<String> names = request.getHeaderNames();
        while (names.hasMoreElements()) {
            String name = names.nextElement();
            headers.put(name, request.getHeader(name));
        }
        Map<String, String> notify = wxPayService.verifyNotify(body, headers);
        String payNo = notify.get("out_trade_no");
        if (payNo == null) {
            // 骨架阶段未接入验签：记录原文，避免丢失真实回调
            log.warn("微信支付回调未解析出 payNo，原文长度={}", body == null ? 0 : body.length());
            return Map.of("code", "FAIL", "message", "回调解析失败");
        }
        orderMessageProducer.sendPayNotify(payNo, notify.get("transaction_id"), "WECHAT");
        return Map.of("code", "SUCCESS", "message", "OK");
    }

    @PostMapping("/alipay")
    public String alipayNotify(@RequestBody(required = false) String body) {
        log.info("支付宝回调（骨架）：{}", body);
        return "success";
    }
}
