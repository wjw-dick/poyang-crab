package com.xiegongzhu.crab.module.system.controller;

import com.xiegongzhu.crab.common.annotation.AuditLog;
import com.xiegongzhu.crab.common.controller.BaseCrudController;
import com.xiegongzhu.crab.common.result.R;
import com.xiegongzhu.crab.module.system.entity.SysUser;
import com.xiegongzhu.crab.module.system.service.SysUserService;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * 后台用户管理（超管全量 CRUD + 重置密码）
 */
@RestController
@RequestMapping("/system/user")
public class SysUserController extends BaseCrudController<SysUser, SysUserService> {

    @AuditLog(module = "用户管理", operation = "UPDATE")
    @PutMapping("/{id}/password")
    public R<Void> resetPassword(@PathVariable Long id, @RequestParam String password) {
        service.resetPassword(id, password);
        return R.ok();
    }
}
