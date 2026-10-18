package com.xiegongzhu.crab.module.system.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.xiegongzhu.crab.common.entity.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * T31 敏感词
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("sys_sensitive_word")
public class SysSensitiveWord extends BaseEntity {

    private static final long serialVersionUID = 1L;

    private String word;
    /** 1 替换 / 2 拦截 */
    private Integer level;
}
