package com.xiegongzhu.crab.module.trade.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.xiegongzhu.crab.common.entity.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 冷链物流（顺丰单号与轨迹）
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("t_order_delivery")
public class OrderDelivery extends BaseEntity {

    private static final long serialVersionUID = 1L;

    private String orderNo;
    private String expressCompany;
    private String expressNo;
    private Integer coldChain;
    private String packCheck;
    private Long packerId;
    private String shipStatus;
    private String trackJson;
    private LocalDateTime expressPrintTime;
    private LocalDateTime outboundTime;
    private LocalDateTime shipTime;
    private LocalDateTime signedTime;}