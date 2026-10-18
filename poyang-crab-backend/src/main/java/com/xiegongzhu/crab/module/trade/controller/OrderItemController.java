package com.xiegongzhu.crab.module.trade.controller;

import com.xiegongzhu.crab.common.controller.BaseCrudController;
import com.xiegongzhu.crab.module.trade.entity.OrderItem;
import com.xiegongzhu.crab.module.trade.service.OrderItemService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 订单明细 通用 CRUD（PRO.md 6.2：除审计日志外超管可完整增删改查）
 */
@RestController
@RequestMapping("/trade/order-item")
public class OrderItemController extends BaseCrudController<OrderItem, OrderItemService> {
}