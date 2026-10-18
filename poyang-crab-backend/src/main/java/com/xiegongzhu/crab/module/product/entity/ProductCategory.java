package com.xiegongzhu.crab.module.product.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.xiegongzhu.crab.common.entity.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 商品分类
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("product_category")
public class ProductCategory extends BaseEntity {

    private static final long serialVersionUID = 1L;

    private Long parentId;
    private String categoryName;
    private String categoryNameEn;
    private String icon;
    private Integer sort;
    private Integer status;}