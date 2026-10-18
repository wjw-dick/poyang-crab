package com.xiegongzhu.crab.module.system.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * T14 审计日志（只读：不提供 update/delete 接口）
 * 该表无逻辑删除字段，故不继承 BaseEntity
 */
@Data
@TableName("sys_audit_log")
public class SysAuditLog implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long userId;
    private String username;
    private String module;
    private String operation;
    private String method;
    private String requestUri;
    private String requestParam;
    private String ip;
    private String userAgent;
    private Integer success;
    private String errorMsg;
    private Long costMs;
    private LocalDateTime createTime;
}
