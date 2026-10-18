package com.xiegongzhu.crab.module.member.controller;

import com.xiegongzhu.crab.common.controller.BaseCrudController;
import com.xiegongzhu.crab.module.member.entity.MemberCouponLog;
import com.xiegongzhu.crab.module.member.service.MemberCouponLogService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 卡券领取/核销记录 通用 CRUD（PRO.md 6.2：除审计日志外超管可完整增删改查）
 */
@RestController
@RequestMapping("/member/coupon-log")
public class MemberCouponLogController extends BaseCrudController<MemberCouponLog, MemberCouponLogService> {
}