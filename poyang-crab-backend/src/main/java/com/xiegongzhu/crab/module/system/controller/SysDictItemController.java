package com.xiegongzhu.crab.module.system.controller;

import com.xiegongzhu.crab.common.controller.BaseCrudController;
import com.xiegongzhu.crab.module.system.entity.SysDictItem;
import com.xiegongzhu.crab.module.system.service.SysDictItemService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 字典项 通用 CRUD（PRO.md 6.2：除审计日志外超管可完整增删改查）
 */
@RestController
@RequestMapping("/system/dict-item")
public class SysDictItemController extends BaseCrudController<SysDictItem, SysDictItemService> {
}