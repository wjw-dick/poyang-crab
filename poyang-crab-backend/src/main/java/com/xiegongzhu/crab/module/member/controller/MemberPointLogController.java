package com.xiegongzhu.crab.module.member.controller;

import com.xiegongzhu.crab.common.controller.BaseCrudController;
import com.xiegongzhu.crab.module.member.entity.MemberPointLog;
import com.xiegongzhu.crab.module.member.service.MemberPointLogService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 积分流水 通用 CRUD（PRO.md 6.2：除审计日志外超管可完整增删改查）
 */
@RestController
@RequestMapping("/member/point-log")
public class MemberPointLogController extends BaseCrudController<MemberPointLog, MemberPointLogService> {
}