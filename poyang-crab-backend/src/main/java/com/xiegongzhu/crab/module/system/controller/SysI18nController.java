package com.xiegongzhu.crab.module.system.controller;

import com.xiegongzhu.crab.common.controller.BaseCrudController;
import com.xiegongzhu.crab.module.system.entity.SysI18n;
import com.xiegongzhu.crab.module.system.service.SysI18nService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 多语言词条 通用 CRUD（PRO.md 6.2：除审计日志外超管可完整增删改查）
 */
@RestController
@RequestMapping("/system/i18n")
public class SysI18nController extends BaseCrudController<SysI18n, SysI18nService> {
}