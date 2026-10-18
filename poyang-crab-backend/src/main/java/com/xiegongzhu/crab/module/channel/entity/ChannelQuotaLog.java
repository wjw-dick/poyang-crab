package com.xiegongzhu.crab.module.channel.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.xiegongzhu.crab.common.entity.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 渠道额度流水
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("t_channel_quota_log")
public class ChannelQuotaLog extends BaseEntity {

    private static final long serialVersionUID = 1L;

    private Long channelId;
    private String changeType;
    private BigDecimal amount;
    private BigDecimal beforeQuota;
    private BigDecimal afterQuota;
    private String bizNo;}