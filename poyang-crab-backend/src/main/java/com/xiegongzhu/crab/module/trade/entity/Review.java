package com.xiegongzhu.crab.module.trade.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.xiegongzhu.crab.common.entity.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 收货评价
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("t_review")
public class Review extends BaseEntity {

    private static final long serialVersionUID = 1L;

    private String orderNo;
    private Long memberId;
    private Long productId;
    private Long skuId;
    private Integer score;
    private String content;
    private String images;
    private Integer survivalRate;
    private Integer isShow;
    private String replyContent;}