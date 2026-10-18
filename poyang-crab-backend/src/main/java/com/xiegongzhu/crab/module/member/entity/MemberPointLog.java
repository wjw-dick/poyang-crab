package com.xiegongzhu.crab.module.member.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.xiegongzhu.crab.common.entity.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 积分流水
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("member_point_log")
public class MemberPointLog extends BaseEntity {

    private static final long serialVersionUID = 1L;

    private Long memberId;
    private String changeType;
    private Integer points;
    private Integer beforePoints;
    private Integer afterPoints;
    private String source;
    private String bizNo;}