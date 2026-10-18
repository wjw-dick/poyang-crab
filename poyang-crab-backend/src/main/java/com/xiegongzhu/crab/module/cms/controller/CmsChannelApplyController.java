package com.xiegongzhu.crab.module.cms.controller;

import com.xiegongzhu.crab.common.controller.BaseCrudController;
import com.xiegongzhu.crab.module.cms.entity.CmsChannelApply;
import com.xiegongzhu.crab.module.cms.service.CmsChannelApplyService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 渠道商申请（PC 官网招商） 通用 CRUD（PRO.md 6.2：除审计日志外超管可完整增删改查）
 */
@RestController
@RequestMapping("/cms/apply")
public class CmsChannelApplyController extends BaseCrudController<CmsChannelApply, CmsChannelApplyService> {
}