package com.xiegongzhu.crab.module.channel.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.xiegongzhu.crab.common.entity.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 对账结算单
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("t_settlement")
public class Settlement extends BaseEntity {

    private static final long serialVersionUID = 1L;

    private String settleNo;
    private Long channelId;
    private LocalDate periodStart;
    private LocalDate periodEnd;
    private BigDecimal orderAmount;
    private BigDecimal commissionAmount;
    private BigDecimal settleAmount;
    private String status;
    private LocalDateTime confirmTime;
    private LocalDateTime payTime;}