package com.xiegongzhu.crab.module.cms.controller;

import com.xiegongzhu.crab.common.controller.BaseCrudController;
import com.xiegongzhu.crab.module.cms.entity.CmsCategory;
import com.xiegongzhu.crab.module.cms.service.CmsCategoryService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * CMS 栏目 通用 CRUD（PRO.md 6.2：除审计日志外超管可完整增删改查）
 */
@RestController
@RequestMapping("/cms/category")
public class CmsCategoryController extends BaseCrudController<CmsCategory, CmsCategoryService> {
}