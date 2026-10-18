package com.xiegongzhu.crab.module.member.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.xiegongzhu.crab.common.entity.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 会员收货地址
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("member_address")
public class MemberAddress extends BaseEntity {

    private static final long serialVersionUID = 1L;

    private Long memberId;
    private String contact;
    private String mobile;
    private String province;
    private String city;
    private String district;
    private String detail;
    private Integer isDefault;}