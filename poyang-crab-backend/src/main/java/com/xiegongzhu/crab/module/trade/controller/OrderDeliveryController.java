package com.xiegongzhu.crab.module.trade.controller;

import com.xiegongzhu.crab.common.controller.BaseCrudController;
import com.xiegongzhu.crab.module.trade.entity.OrderDelivery;
import com.xiegongzhu.crab.module.trade.service.OrderDeliveryService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 冷链物流（顺丰单号与轨迹） 通用 CRUD（PRO.md 6.2：除审计日志外超管可完整增删改查）
 */
@RestController
@RequestMapping("/trade/delivery")
public class OrderDeliveryController extends BaseCrudController<OrderDelivery, OrderDeliveryService> {
}