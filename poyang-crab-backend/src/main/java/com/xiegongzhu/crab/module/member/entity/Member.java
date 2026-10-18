package com.xiegongzhu.crab.module.member.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.xiegongzhu.crab.common.entity.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 会员（公众号/小程序/H5 UnionID 互通）
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("member")
public class Member extends BaseEntity {

    private static final long serialVersionUID = 1L;

    private String unionId;
    private String openIdMp;
    private String openIdMini;
    private String openIdH5;
    private String nickname;
    private String avatar;
    private String mobile;
    private Integer gender;
    private String memberLevel;
    private Integer points;
    private BigDecimal balance;
    private Long channelId;
    private Integer status;}