package com.xiegongzhu.crab.module.member.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.xiegongzhu.crab.common.entity.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 储值流水
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("member_balance_log")
public class MemberBalanceLog extends BaseEntity {

    private static final long serialVersionUID = 1L;

    private Long memberId;
    private String changeType;
    private BigDecimal amount;
    private BigDecimal beforeBalance;
    private BigDecimal afterBalance;
    private String bizNo;}