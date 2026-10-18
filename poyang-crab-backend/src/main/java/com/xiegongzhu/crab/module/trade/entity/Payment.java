package com.xiegongzhu.crab.module.trade.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.xiegongzhu.crab.common.entity.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 支付流水（微信/支付宝/储值）
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("t_payment")
public class Payment extends BaseEntity {

    private static final long serialVersionUID = 1L;

    private String payNo;
    private String orderNo;
    private String payType;
    private String tradeNo;
    private BigDecimal amount;
    private String payStatus;
    private String notifyRaw;
    private BigDecimal refundAmount;
    private LocalDateTime payTime;}