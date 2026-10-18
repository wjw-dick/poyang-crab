package com.xiegongzhu.crab.module.product.controller;

import com.xiegongzhu.crab.common.controller.BaseCrudController;
import com.xiegongzhu.crab.module.product.entity.Stock;
import com.xiegongzhu.crab.module.product.service.StockService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 库存（自营 + 批发共用） 通用 CRUD（PRO.md 6.2：除审计日志外超管可完整增删改查）
 */
@RestController
@RequestMapping("/product/stock")
public class StockController extends BaseCrudController<Stock, StockService> {
}