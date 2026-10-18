package com.xiegongzhu.crab.module.member.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.xiegongzhu.crab.common.entity.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 卡券模板
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("member_coupon")
public class MemberCoupon extends BaseEntity {

    private static final long serialVersionUID = 1L;

    private String couponName;
    private String couponType;
    private BigDecimal threshold;
    private BigDecimal discountAmount;
    private BigDecimal discountRate;
    private Integer totalQty;
    private Integer usedQty;
    private LocalDateTime validStart;
    private LocalDateTime validEnd;
    private Integer status;}