package com.xiegongzhu.crab.module.channel.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.xiegongzhu.crab.common.entity.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 渠道报单
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("t_channel_order")
public class ChannelOrder extends BaseEntity {

    private static final long serialVersionUID = 1L;

    private String reportNo;
    private Long channelId;
    private String orderNo;
    private Integer totalQty;
    private BigDecimal totalAmount;
    private String auditStatus;
    private Long auditBy;
    private LocalDateTime auditTime;
    private String auditRemark;}