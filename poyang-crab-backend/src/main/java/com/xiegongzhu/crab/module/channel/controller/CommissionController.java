package com.xiegongzhu.crab.module.channel.controller;

import com.xiegongzhu.crab.common.controller.BaseCrudController;
import com.xiegongzhu.crab.module.channel.entity.Commission;
import com.xiegongzhu.crab.module.channel.service.CommissionService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 佣金/转介绍返佣 通用 CRUD（PRO.md 6.2：除审计日志外超管可完整增删改查）
 */
@RestController
@RequestMapping("/channel/commission")
public class CommissionController extends BaseCrudController<Commission, CommissionService> {
}