package com.xiegongzhu.crab.module.product.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.xiegongzhu.crab.common.entity.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 商品（鄱阳湖湖蟹）
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("product")
public class Product extends BaseEntity {

    private static final long serialVersionUID = 1L;

    private String productNo;
    private Long categoryId;
    private String productName;
    private String productNameEn;
    private String mainImage;
    private String images;
    private String detailHtml;
    private String detailHtmlEn;
    private String origin;
    private String sellMode;
    private BigDecimal retailPrice;
    private BigDecimal wholesalePrice;
    private Integer minOrderQty;
    private Long liveRoomId;
    private String seoTitle;
    private String seoKeywords;
    private String seoDesc;
    private Integer status;
    private Integer sort;}