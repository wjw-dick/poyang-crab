-- =============================================================
-- T03 CMS 域：栏目 / 文章（双语 SEO，富文本走对象存储）
-- =============================================================
USE `poyang_crab`;

CREATE TABLE IF NOT EXISTS `cms_category` (
  `id`              BIGINT      NOT NULL AUTO_INCREMENT,
  `parent_id`       BIGINT      NOT NULL DEFAULT 0,
  `category_name`   VARCHAR(64) NOT NULL,
  `category_name_en` VARCHAR(64)         DEFAULT NULL,
  `category_code`   VARCHAR(64) NOT NULL COMMENT 'brand/base/catch/recruit/notice',
  `sort`            INT         NOT NULL DEFAULT 0,
  `status`          TINYINT     NOT NULL DEFAULT 1,
  `create_time`     DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time`     DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted`         TINYINT     NOT NULL DEFAULT 0,
  `version`         INT         NOT NULL DEFAULT 0,
  `remark`          VARCHAR(255)         DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_cms_category_code` (`category_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='CMS 栏目';

CREATE TABLE IF NOT EXISTS `cms_article` (
  `id`            BIGINT       NOT NULL AUTO_INCREMENT,
  `category_id`   BIGINT       NOT NULL,
  `title`         VARCHAR(255) NOT NULL,
  `title_en`      VARCHAR(255)          DEFAULT NULL,
  `summary`       VARCHAR(512)          DEFAULT NULL,
  `summary_en`    VARCHAR(512)          DEFAULT NULL,
  `cover`         VARCHAR(512)          DEFAULT NULL,
  `content_html`  LONGTEXT              DEFAULT NULL COMMENT '富文本（中文 tab）',
  `content_html_en` LONGTEXT            DEFAULT NULL COMMENT '富文本（英文 tab）',
  `seo_title`     VARCHAR(255)          DEFAULT NULL,
  `seo_keywords`  VARCHAR(255)          DEFAULT NULL,
  `seo_desc`      VARCHAR(512)          DEFAULT NULL,
  `is_top`        TINYINT      NOT NULL DEFAULT 0,
  `status`        VARCHAR(16)  NOT NULL DEFAULT 'DRAFT' COMMENT 'DRAFT/PUBLISHED',
  `publish_time`  DATETIME              DEFAULT NULL,
  `view_count`    INT          NOT NULL DEFAULT 0,
  `create_time`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted`       TINYINT      NOT NULL DEFAULT 0,
  `version`       INT          NOT NULL DEFAULT 0,
  `remark`        VARCHAR(255)          DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_article_category` (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='CMS 文章';

-- 渠道商申请（PC 官网招商表单落地）
CREATE TABLE IF NOT EXISTS `cms_channel_apply` (
  `id`            BIGINT      NOT NULL AUTO_INCREMENT,
  `company_name`  VARCHAR(128) NOT NULL,
  `contact_name`  VARCHAR(64)  NOT NULL,
  `contact_mobile` VARCHAR(20)  NOT NULL,
  `region`        VARCHAR(128)          DEFAULT NULL,
  `intention`     VARCHAR(1024)         DEFAULT NULL,
  `audit_status`  VARCHAR(16)  NOT NULL DEFAULT 'PENDING' COMMENT 'PENDING/APPROVED/REJECTED',
  `audit_remark`  VARCHAR(255)          DEFAULT NULL,
  `create_time`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted`       TINYINT      NOT NULL DEFAULT 0,
  `version`       INT          NOT NULL DEFAULT 0,
  `remark`        VARCHAR(255)          DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='渠道商申请';
