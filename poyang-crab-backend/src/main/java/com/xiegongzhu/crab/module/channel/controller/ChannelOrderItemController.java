package com.xiegongzhu.crab.module.channel.controller;

import com.xiegongzhu.crab.common.controller.BaseCrudController;
import com.xiegongzhu.crab.module.channel.entity.ChannelOrderItem;
import com.xiegongzhu.crab.module.channel.service.ChannelOrderItemService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 渠道报单明细 通用 CRUD（PRO.md 6.2：除审计日志外超管可完整增删改查）
 */
@RestController
@RequestMapping("/channel/report-item")
public class ChannelOrderItemController extends BaseCrudController<ChannelOrderItem, ChannelOrderItemService> {
}