package com.xiegongzhu.crab.module.trade.controller;

import com.xiegongzhu.crab.common.controller.BaseCrudController;
import com.xiegongzhu.crab.module.trade.entity.Payment;
import com.xiegongzhu.crab.module.trade.service.PaymentService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 支付流水（微信/支付宝/储值） 通用 CRUD（PRO.md 6.2：除审计日志外超管可完整增删改查）
 */
@RestController
@RequestMapping("/trade/payment")
public class PaymentController extends BaseCrudController<Payment, PaymentService> {
}