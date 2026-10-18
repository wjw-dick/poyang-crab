package com.xiegongzhu.crab.module.product.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.xiegongzhu.crab.common.entity.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 湖蟹规格（公母/重量档/只数礼盒）
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("product_spec")
public class ProductSpec extends BaseEntity {

    private static final long serialVersionUID = 1L;

    private Long productId;
    private String crabSex;
    private String weightLevel;
    private BigDecimal weightMin;
    private BigDecimal weightMax;
    private Integer pieceCount;
    private String packType;}