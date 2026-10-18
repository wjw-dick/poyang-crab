package com.xiegongzhu.crab.module.channel.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.xiegongzhu.crab.common.entity.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 渠道商（经销商/代理）
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("t_channel")
public class Channel extends BaseEntity {

    private static final long serialVersionUID = 1L;

    private String channelNo;
    private String channelName;
    private String contactName;
    private String contactMobile;
    private String unionId;
    private String channelLevel;
    private Long parentId;
    private BigDecimal commissionRate;
    private BigDecimal referralRate;
    private BigDecimal creditQuota;
    private BigDecimal usedQuota;
    private BigDecimal timePrice;
    private String status;
    private String licenseImages;}