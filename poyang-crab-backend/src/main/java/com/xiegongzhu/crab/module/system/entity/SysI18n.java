package com.xiegongzhu.crab.module.system.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.xiegongzhu.crab.common.entity.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * T09 多语言词条
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("sys_i18n")
public class SysI18n extends BaseEntity {

    private static final long serialVersionUID = 1L;

    private String itemKey;
    private String langCode;
    private String itemValue;
}
