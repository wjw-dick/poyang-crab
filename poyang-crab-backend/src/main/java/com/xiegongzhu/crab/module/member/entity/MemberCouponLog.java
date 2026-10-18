package com.xiegongzhu.crab.module.member.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.xiegongzhu.crab.common.entity.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 卡券领取/核销记录
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("member_coupon_log")
public class MemberCouponLog extends BaseEntity {

    private static final long serialVersionUID = 1L;

    private Long couponId;
    private Long memberId;
    private String status;
    private String orderNo;
    private LocalDateTime usedTime;}