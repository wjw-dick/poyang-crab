package com.xiegongzhu.crab.common.annotation;

import java.lang.annotation.Documented;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * T14 审计日志注解：标注的方法将被 AuditLogAspect 记录到 sys_audit_log（只读，禁改）
 */
@Documented
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface AuditLog {

    /** 模块名，如 系统参数 / 商品管理 / 渠道商管理 */
    String module();

    /** 操作类型：CREATE/UPDATE/DELETE/QUERY/LOGIN/PUBLISH/EXPORT */
    String operation();

    /** 是否记录请求参数 */
    boolean saveParam() default true;
}
