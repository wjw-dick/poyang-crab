package com.xiegongzhu.crab.module.cms.controller;

import com.xiegongzhu.crab.common.controller.BaseCrudController;
import com.xiegongzhu.crab.module.cms.entity.CmsArticle;
import com.xiegongzhu.crab.module.cms.service.CmsArticleService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * CMS 文章（双语 SEO / 富文本） 通用 CRUD（PRO.md 6.2：除审计日志外超管可完整增删改查）
 */
@RestController
@RequestMapping("/cms/article")
public class CmsArticleController extends BaseCrudController<CmsArticle, CmsArticleService> {
}