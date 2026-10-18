package com.xiegongzhu.crab.module.channel.controller;

import com.xiegongzhu.crab.common.controller.BaseCrudController;
import com.xiegongzhu.crab.module.channel.entity.ChannelQuotaLog;
import com.xiegongzhu.crab.module.channel.service.ChannelQuotaLogService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 渠道额度流水 通用 CRUD（PRO.md 6.2：除审计日志外超管可完整增删改查）
 */
@RestController
@RequestMapping("/channel/quota-log")
public class ChannelQuotaLogController extends BaseCrudController<ChannelQuotaLog, ChannelQuotaLogService> {
}