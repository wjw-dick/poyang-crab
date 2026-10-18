package com.xiegongzhu.crab.module.cms.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.xiegongzhu.crab.common.entity.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * CMS 栏目
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cms_category")
public class CmsCategory extends BaseEntity {

    private static final long serialVersionUID = 1L;

    private Long parentId;
    private String categoryName;
    private String categoryNameEn;
    private String categoryCode;
    private Integer sort;
    private Integer status;}