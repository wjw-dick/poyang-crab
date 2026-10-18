package com.xiegongzhu.crab.module.product.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.xiegongzhu.crab.common.entity.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 库存（自营 + 批发共用）
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("stock")
public class Stock extends BaseEntity {

    private static final long serialVersionUID = 1L;

    private Long skuId;
    private String warehouse;
    private Integer totalQty;
    private Integer availableQty;
    private Integer lockedQty;
    private Integer warnQty;}