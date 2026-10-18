package com.xiegongzhu.crab.module.system.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.xiegongzhu.crab.common.entity.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * T09 语言列表
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("sys_lang")
public class SysLang extends BaseEntity {

    private static final long serialVersionUID = 1L;

    private String langCode;
    private String langName;
    private Integer isDefault;
    private Integer status;
    private Integer sort;
}
