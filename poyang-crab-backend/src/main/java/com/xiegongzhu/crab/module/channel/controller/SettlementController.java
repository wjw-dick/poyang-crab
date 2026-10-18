package com.xiegongzhu.crab.module.channel.controller;

import com.xiegongzhu.crab.common.controller.BaseCrudController;
import com.xiegongzhu.crab.module.channel.entity.Settlement;
import com.xiegongzhu.crab.module.channel.service.SettlementService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 对账结算单 通用 CRUD（PRO.md 6.2：除审计日志外超管可完整增删改查）
 */
@RestController
@RequestMapping("/channel/settlement")
public class SettlementController extends BaseCrudController<Settlement, SettlementService> {
}