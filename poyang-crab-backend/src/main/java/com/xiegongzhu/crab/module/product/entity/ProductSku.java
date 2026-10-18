package com.xiegongzhu.crab.module.product.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.xiegongzhu.crab.common.entity.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 商品 SKU
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("product_sku")
public class ProductSku extends BaseEntity {

    private static final long serialVersionUID = 1L;

    private Long productId;
    private Long specId;
    private String skuNo;
    private String skuName;
    private BigDecimal retailPrice;
    private BigDecimal wholesalePrice;
    private BigDecimal costPrice;
    private String image;
    private Integer status;}