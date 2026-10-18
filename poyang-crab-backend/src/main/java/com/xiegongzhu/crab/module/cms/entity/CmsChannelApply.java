package com.xiegongzhu.crab.module.cms.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.xiegongzhu.crab.common.entity.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 渠道商申请（PC 官网招商）
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cms_channel_apply")
public class CmsChannelApply extends BaseEntity {

    private static final long serialVersionUID = 1L;

    private String companyName;
    private String contactName;
    private String contactMobile;
    private String region;
    private String intention;
    private String auditStatus;
    private String auditRemark;}