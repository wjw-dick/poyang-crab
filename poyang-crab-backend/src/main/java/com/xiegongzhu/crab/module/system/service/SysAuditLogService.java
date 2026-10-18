package com.xiegongzhu.crab.module.system.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.xiegongzhu.crab.module.system.entity.SysAuditLog;

/**
 * T14 审计日志：只读。本接口不提供任何新增/修改/删除能力（PRO.md 6.2 红线）
 */
public interface SysAuditLogService extends IService<SysAuditLog> {

    Page<SysAuditLog> pageQuery(long current, long size, String username, String module, String operation);
}
