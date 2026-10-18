package com.xiegongzhu.crab.module.trade.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.xiegongzhu.crab.common.entity.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 订单（自营 + 批发）
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("t_order")
public class Order extends BaseEntity {

    private static final long serialVersionUID = 1L;

    private String orderNo;
    private Long memberId;
    private String bizMode;
    private Long channelId;
    private String orderStatus;
    private String payStatus;
    private BigDecimal totalAmount;
    private BigDecimal discountAmount;
    private BigDecimal freightAmount;
    private BigDecimal payAmount;
    private Long couponId;
    private String payType;
    private LocalDateTime payTime;
    private String receiverName;
    private String receiverMobile;
    private String receiverAddress;
    private LocalDateTime expireTime;
    private String cancelReason;
    private String source;}