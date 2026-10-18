package com.xiegongzhu.crab.module.channel.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.xiegongzhu.crab.common.entity.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 渠道下级关系树
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("t_channel_relation")
public class ChannelRelation extends BaseEntity {

    private static final long serialVersionUID = 1L;

    private Long channelId;
    private Long parentId;
    private String path;
    private Integer level;}