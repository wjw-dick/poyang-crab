package com.xiegongzhu.crab.module.system.controller;

import com.xiegongzhu.crab.common.controller.BaseCrudController;
import com.xiegongzhu.crab.module.system.entity.SysRole;
import com.xiegongzhu.crab.module.system.service.SysRoleService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * RBAC 角色 通用 CRUD（PRO.md 6.2：除审计日志外超管可完整增删改查）
 */
@RestController
@RequestMapping("/system/role")
public class SysRoleController extends BaseCrudController<SysRole, SysRoleService> {
}