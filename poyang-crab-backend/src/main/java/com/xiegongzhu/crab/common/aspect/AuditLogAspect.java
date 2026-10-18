package com.xiegongzhu.crab.common.aspect;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.xiegongzhu.crab.common.annotation.AuditLog;
import com.xiegongzhu.crab.common.security.CurrentUserHolder;
import com.xiegongzhu.crab.common.security.LoginUser;
import com.xiegongzhu.crab.module.system.entity.SysAuditLog;
import com.xiegongzhu.crab.module.system.mapper.SysAuditLogMapper;
import jakarta.servlet.http.HttpServletRequest;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.time.LocalDateTime;

/**
 * T14 全操作审计：记录操作人 / 模块 / 操作 / 入参 / IP / 耗时 / 结果
 * 审计写入失败不得影响主流程
 */
@Aspect
@Component
public class AuditLogAspect {

    private static final Logger log = LoggerFactory.getLogger(AuditLogAspect.class);
    private static final int MAX_PARAM_LENGTH = 4000;

    private final SysAuditLogMapper auditLogMapper;
    private final ObjectMapper objectMapper;

    public AuditLogAspect(SysAuditLogMapper auditLogMapper, ObjectMapper objectMapper) {
        this.auditLogMapper = auditLogMapper;
        this.objectMapper = objectMapper;
    }

    @Around("@annotation(auditLog)")
    public Object around(ProceedingJoinPoint point, AuditLog auditLog) throws Throwable {
        long start = System.currentTimeMillis();
        boolean success = true;
        String errorMsg = null;
        try {
            return point.proceed();
        } catch (Throwable e) {
            success = false;
            errorMsg = e.getMessage();
            throw e;
        } finally {
            try {
                saveAuditLog(point, auditLog, System.currentTimeMillis() - start, success, errorMsg);
            } catch (Exception e) {
                log.warn("审计日志写入失败: {}", e.getMessage());
            }
        }
    }

    private void saveAuditLog(ProceedingJoinPoint point, AuditLog auditLog,
                              long costMs, boolean success, String errorMsg) {
        SysAuditLog entity = new SysAuditLog();
        entity.setModule(auditLog.module());
        entity.setOperation(auditLog.operation());
        entity.setMethod(point.getSignature().toShortString());
        entity.setSuccess(success ? 1 : 0);
        entity.setErrorMsg(truncate(errorMsg, 1000));
        entity.setCostMs(costMs);
        entity.setCreateTime(LocalDateTime.now());

        LoginUser user = CurrentUserHolder.get();
        if (user != null) {
            entity.setUserId(user.getUserId());
            entity.setUsername(user.getUsername());
        }

        ServletRequestAttributes attributes =
                (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        if (attributes != null) {
            HttpServletRequest request = attributes.getRequest();
            entity.setRequestUri(request.getRequestURI());
            entity.setIp(clientIp(request));
            entity.setUserAgent(truncate(request.getHeader("User-Agent"), 500));
        }

        if (auditLog.saveParam()) {
            entity.setRequestParam(truncate(toJson(point.getArgs()), MAX_PARAM_LENGTH));
        }
        auditLogMapper.insert(entity);
    }

    private String toJson(Object value) {
        try {
            return objectMapper.writeValueAsString(value);
        } catch (Exception e) {
            return String.valueOf(value);
        }
    }

    private String clientIp(HttpServletRequest request) {
        String forwarded = request.getHeader("X-Forwarded-For");
        if (forwarded != null && !forwarded.isBlank()) {
            return forwarded.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }

    private String truncate(String text, int max) {
        if (text == null) {
            return null;
        }
        return text.length() <= max ? text : text.substring(0, max);
    }
}
