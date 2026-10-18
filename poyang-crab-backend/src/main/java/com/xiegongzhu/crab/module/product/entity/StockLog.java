package com.xiegongzhu.crab.module.product.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.xiegongzhu.crab.common.entity.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 库存流水
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("stock_log")
public class StockLog extends BaseEntity {

    private static final long serialVersionUID = 1L;

    private Long skuId;
    private String warehouse;
    private String changeType;
    private Integer qty;
    private String bizType;
    private String bizNo;}