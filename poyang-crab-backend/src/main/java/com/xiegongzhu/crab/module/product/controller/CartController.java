package com.xiegongzhu.crab.module.product.controller;

import com.xiegongzhu.crab.common.controller.BaseCrudController;
import com.xiegongzhu.crab.module.product.entity.Cart;
import com.xiegongzhu.crab.module.product.service.CartService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 购物车 通用 CRUD（PRO.md 6.2：除审计日志外超管可完整增删改查）
 */
@RestController
@RequestMapping("/cart")
public class CartController extends BaseCrudController<Cart, CartService> {
}