package com.xiegongzhu.crab.module.member.controller;

import com.xiegongzhu.crab.common.controller.BaseCrudController;
import com.xiegongzhu.crab.module.member.entity.MemberCoupon;
import com.xiegongzhu.crab.module.member.service.MemberCouponService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 卡券模板 通用 CRUD（PRO.md 6.2：除审计日志外超管可完整增删改查）
 */
@RestController
@RequestMapping("/member/coupon")
public class MemberCouponController extends BaseCrudController<MemberCoupon, MemberCouponService> {
}