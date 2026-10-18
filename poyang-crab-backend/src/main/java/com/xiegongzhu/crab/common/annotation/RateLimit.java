package com.xiegongzhu.crab.common.annotation;

import java.lang.annotation.Documented;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * T31 接口限流 + 防重
 * 例：@RateLimit(limit = 5, seconds = 60, key = "order:create", dedup = true)
 */
@Documented
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface RateLimit {

    /** 窗口内最大请求数 */
    int limit() default 20;

    /** 窗口秒数 */
    int seconds() default 60;

    /** 限流维度：IP / USER / GLOBAL */
    String dimension() default "IP";

    /** 业务 key 前缀 */
    String key() default "";

    /** 是否同时做重复提交校验（同一用户 + 同一 key 在 seconds 内只允许一次） */
    boolean dedup() default false;
}
