package com.xiegongzhu.crab.module.trade.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.xiegongzhu.crab.common.entity.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 订单明细
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("t_order_item")
public class OrderItem extends BaseEntity {

    private static final long serialVersionUID = 1L;

    private String orderNo;
    private Long orderId;
    private Long productId;
    private Long skuId;
    private String productName;
    private String skuName;
    private String specDesc;
    private BigDecimal price;
    private Integer qty;
    private BigDecimal amount;
    private String image;}