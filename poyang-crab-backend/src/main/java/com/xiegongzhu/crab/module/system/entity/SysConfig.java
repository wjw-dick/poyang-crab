package com.xiegongzhu.crab.module.system.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.xiegongzhu.crab.common.entity.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * T08 系统全局参数：站点 / ICP / 客服 / 微信 / 支付 / 存储 / 业务比例
 * 金额与比例一律走本表，禁止写死
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("sys_config")
public class SysConfig extends BaseEntity {

    private static final long serialVersionUID = 1L;

    private String configKey;
    private String configName;
    /** SITE / ICP / SERVICE / WECHAT / PAY / STORAGE / BUSINESS */
    private String configGroup;
    private String configValue;
    /** STRING / NUMBER / BOOL / JSON */
    private String valueType;
    /** 1 表示密文（AK/SK 等） */
    private Integer isEncrypted;
    private Integer editable;
    private Integer sort;
}
