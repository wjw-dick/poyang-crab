package com.xiegongzhu.crab.module.system.service.impl;

import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.xiegongzhu.crab.module.system.entity.SysAuditLog;
import com.xiegongzhu.crab.module.system.mapper.SysAuditLogMapper;
import com.xiegongzhu.crab.module.system.service.SysAuditLogService;
import org.springframework.stereotype.Service;

@Service
public class SysAuditLogServiceImpl extends ServiceImpl<SysAuditLogMapper, SysAuditLog>
        implements SysAuditLogService {

    @Override
    public Page<SysAuditLog> pageQuery(long current, long size, String username, String module, String operation) {
        return page(new Page<>(current, size), Wrappers.<SysAuditLog>lambdaQuery()
                .like(username != null && !username.isBlank(), SysAuditLog::getUsername, username)
                .eq(module != null && !module.isBlank(), SysAuditLog::getModule, module)
                .eq(operation != null && !operation.isBlank(), SysAuditLog::getOperation, operation)
                .orderByDesc(SysAuditLog::getId));
    }
}
