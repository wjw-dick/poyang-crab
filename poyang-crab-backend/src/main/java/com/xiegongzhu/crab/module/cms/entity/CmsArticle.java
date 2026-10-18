package com.xiegongzhu.crab.module.cms.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.xiegongzhu.crab.common.entity.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * CMS 文章（双语 SEO / 富文本）
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cms_article")
public class CmsArticle extends BaseEntity {

    private static final long serialVersionUID = 1L;

    private Long categoryId;
    private String title;
    private String titleEn;
    private String summary;
    private String summaryEn;
    private String cover;
    private String contentHtml;
    private String contentHtmlEn;
    private String seoTitle;
    private String seoKeywords;
    private String seoDesc;
    private Integer isTop;
    private String status;
    private LocalDateTime publishTime;
    private Integer viewCount;}