package com.xiegongzhu.crab.module.system.controller;

import com.xiegongzhu.crab.common.result.PageResult;
import com.xiegongzhu.crab.common.result.R;
import com.xiegongzhu.crab.module.system.entity.SysAuditLog;
import com.xiegongzhu.crab.module.system.service.SysAuditLogService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * T14 审计日志查询（只读）
 * 注意：本控制器刻意不提供 POST / PUT / DELETE 接口。
 */
@RestController
@RequestMapping("/system/audit")
public class SysAuditLogController {

    private final SysAuditLogService auditLogService;

    public SysAuditLogController(SysAuditLogService auditLogService) {
        this.auditLogService = auditLogService;
    }

    @GetMapping("/page")
    public R<PageResult<SysAuditLog>> page(@RequestParam(defaultValue = "1") long current,
                                           @RequestParam(defaultValue = "10") long size,
                                           @RequestParam(required = false) String username,
                                           @RequestParam(required = false) String module,
                                           @RequestParam(required = false) String operation) {
        return R.ok(PageResult.of(auditLogService.pageQuery(current, size, username, module, operation)));
    }

    @GetMapping("/{id}")
    public R<SysAuditLog> detail(@PathVariable Long id) {
        return R.ok(auditLogService.getById(id));
    }
}
