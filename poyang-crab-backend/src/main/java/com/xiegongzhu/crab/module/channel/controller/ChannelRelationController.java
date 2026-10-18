package com.xiegongzhu.crab.module.channel.controller;

import com.xiegongzhu.crab.common.controller.BaseCrudController;
import com.xiegongzhu.crab.module.channel.entity.ChannelRelation;
import com.xiegongzhu.crab.module.channel.service.ChannelRelationService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 渠道下级关系树 通用 CRUD（PRO.md 6.2：除审计日志外超管可完整增删改查）
 */
@RestController
@RequestMapping("/channel/relation")
public class ChannelRelationController extends BaseCrudController<ChannelRelation, ChannelRelationService> {
}