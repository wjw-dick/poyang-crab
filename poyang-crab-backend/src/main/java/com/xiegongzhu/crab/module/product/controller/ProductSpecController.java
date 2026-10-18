package com.xiegongzhu.crab.module.product.controller;

import com.xiegongzhu.crab.common.controller.BaseCrudController;
import com.xiegongzhu.crab.module.product.entity.ProductSpec;
import com.xiegongzhu.crab.module.product.service.ProductSpecService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 湖蟹规格（公母/重量档/只数礼盒） 通用 CRUD（PRO.md 6.2：除审计日志外超管可完整增删改查）
 */
@RestController
@RequestMapping("/product/spec")
public class ProductSpecController extends BaseCrudController<ProductSpec, ProductSpecService> {
}