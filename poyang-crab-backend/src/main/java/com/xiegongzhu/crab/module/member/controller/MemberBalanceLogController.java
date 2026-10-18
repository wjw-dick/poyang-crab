package com.xiegongzhu.crab.module.member.controller;

import com.xiegongzhu.crab.common.controller.BaseCrudController;
import com.xiegongzhu.crab.module.member.entity.MemberBalanceLog;
import com.xiegongzhu.crab.module.member.service.MemberBalanceLogService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 储值流水 通用 CRUD（PRO.md 6.2：除审计日志外超管可完整增删改查）
 */
@RestController
@RequestMapping("/member/balance-log")
public class MemberBalanceLogController extends BaseCrudController<MemberBalanceLog, MemberBalanceLogService> {
}