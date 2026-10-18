package com.xiegongzhu.crab.module.channel.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.xiegongzhu.crab.common.entity.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 渠道报单明细
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("t_channel_order_item")
public class ChannelOrderItem extends BaseEntity {

    private static final long serialVersionUID = 1L;

    private String reportNo;
    private Long channelId;
    private Long productId;
    private Long skuId;
    private String skuName;
    private BigDecimal channelPrice;
    private Integer qty;
    private BigDecimal amount;}