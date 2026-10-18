package com.xiegongzhu.crab.module.channel.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.xiegongzhu.crab.common.entity.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 佣金/转介绍返佣
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("t_commission")
public class Commission extends BaseEntity {

    private static final long serialVersionUID = 1L;

    private String commissionNo;
    private Long channelId;
    private Long fromChannelId;
    private String orderNo;
    private String commissionType;
    private BigDecimal baseAmount;
    private BigDecimal rate;
    private BigDecimal amount;
    private String settleStatus;
    private String settleNo;}