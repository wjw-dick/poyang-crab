package com.xiegongzhu.crab.module.product.controller;

import com.xiegongzhu.crab.common.controller.BaseCrudController;
import com.xiegongzhu.crab.module.product.entity.Product;
import com.xiegongzhu.crab.module.product.service.ProductService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 商品（鄱阳湖湖蟹） 通用 CRUD（PRO.md 6.2：除审计日志外超管可完整增删改查）
 */
@RestController
@RequestMapping("/product")
public class ProductController extends BaseCrudController<Product, ProductService> {
}