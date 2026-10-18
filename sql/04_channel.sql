-- =============================================================
-- T03 渠道域（分销批发）：渠道商 / 下级关系 / 报单 / 佣金 / 对账结算 / 额度
-- 比例一律后台可配置（sys_config: BUSINESS 分组）
-- =============================================================
USE `poyang_crab`;

CREATE TABLE IF NOT EXISTS `t_channel` (
  `id`              BIGINT        NOT NULL AUTO_INCREMENT,
  `channel_no`      VARCHAR(64)   NOT NULL,
  `channel_name`    VARCHAR(128)  NOT NULL,
  `contact_name`    VARCHAR(64)   NOT NULL,
  `contact_mobile`  VARCHAR(20)   NOT NULL,
  `union_id`        VARCHAR(64)            DEFAULT NULL COMMENT 'UnionID 体系登录',
  `channel_level`   VARCHAR(16)   NOT NULL DEFAULT 'L1' COMMENT 'L1/L2/L3',
  `parent_id`       BIGINT        NOT NULL DEFAULT 0 COMMENT '上级渠道（0 顶级）',
  `commission_rate` DECIMAL(5,2)  NOT NULL DEFAULT 0.00 COMMENT '分销佣金比例 %（后台可配置）',
  `referral_rate`   DECIMAL(5,2)  NOT NULL DEFAULT 0.00 COMMENT '转介绍返佣比例 %（后台可配置）',
  `credit_quota`    DECIMAL(14,2) NOT NULL DEFAULT 0.00 COMMENT '授信额度',
  `used_quota`      DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  `time_price`      DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT '年返/吞吐返点（丙方口径）',
  `status`          VARCHAR(16)   NOT NULL DEFAULT 'PENDING' COMMENT 'PENDING待审核/NORMAL/REJECTED/FROZEN',
  `license_images`  TEXT                   DEFAULT NULL COMMENT '资质图片 JSON',
  `create_time`     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time`     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted`         TINYINT       NOT NULL DEFAULT 0,
  `version`         INT           NOT NULL DEFAULT 0,
  `remark`          VARCHAR(255)           DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_channel_no` (`channel_no`),
  UNIQUE KEY `uk_channel_union` (`union_id`),
  KEY `idx_channel_parent` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='渠道商（经销商/代理）';

-- 下级关系（树形，冗余 path 便于查询）
CREATE TABLE IF NOT EXISTS `t_channel_relation` (
  `id`          BIGINT      NOT NULL AUTO_INCREMENT,
  `channel_id`  BIGINT      NOT NULL,
  `parent_id`   BIGINT      NOT NULL DEFAULT 0,
  `path`        VARCHAR(512) NOT NULL DEFAULT '' COMMENT '0/1/5 形式祖先链',
  `level`       INT         NOT NULL DEFAULT 1,
  `create_time` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted`     TINYINT     NOT NULL DEFAULT 0,
  `version`     INT         NOT NULL DEFAULT 0,
  `remark`      VARCHAR(255)         DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_relation_channel` (`channel_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='渠道下级关系';

-- 渠道报单（批发订单，审核后转正式订单）
CREATE TABLE IF NOT EXISTS `t_channel_order` (
  `id`            BIGINT        NOT NULL AUTO_INCREMENT,
  `report_no`     VARCHAR(64)   NOT NULL COMMENT '报单号',
  `channel_id`    BIGINT        NOT NULL,
  `order_no`      VARCHAR(64)            DEFAULT NULL COMMENT '审核通过后生成的自营订单号',
  `total_qty`     INT           NOT NULL DEFAULT 0,
  `total_amount`  DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `audit_status`  VARCHAR(16)   NOT NULL DEFAULT 'PENDING' COMMENT 'PENDING/APPROVED/REJECTED',
  `audit_by`      BIGINT                 DEFAULT NULL,
  `audit_time`    DATETIME               DEFAULT NULL,
  `audit_remark`  VARCHAR(255)           DEFAULT NULL,
  `create_time`   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time`   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted`       TINYINT       NOT NULL DEFAULT 0,
  `version`       INT           NOT NULL DEFAULT 0,
  `remark`        VARCHAR(255)           DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_report_no` (`report_no`),
  KEY `idx_channel_order_channel` (`channel_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='渠道报单';

CREATE TABLE IF NOT EXISTS `t_channel_order_item` (
  `id`          BIGINT        NOT NULL AUTO_INCREMENT,
  `report_no`   VARCHAR(64)   NOT NULL,
  `channel_id`  BIGINT        NOT NULL,
  `product_id`  BIGINT        NOT NULL,
  `sku_id`      BIGINT        NOT NULL,
  `sku_name`    VARCHAR(128)  NOT NULL,
  `channel_price` DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT '渠道专属价',
  `qty`         INT           NOT NULL DEFAULT 1,
  `amount`      DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `create_time` DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted`     TINYINT       NOT NULL DEFAULT 0,
  `version`     INT           NOT NULL DEFAULT 0,
  `remark`      VARCHAR(255)           DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_channel_item_report` (`report_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='渠道报单明细';

-- 佣金 / 转介绍返佣（审计留痕，防渠道纠纷）
CREATE TABLE IF NOT EXISTS `t_commission` (
  `id`            BIGINT        NOT NULL AUTO_INCREMENT,
  `commission_no` VARCHAR(64)   NOT NULL,
  `channel_id`    BIGINT        NOT NULL COMMENT '受益人',
  `from_channel_id` BIGINT               DEFAULT NULL COMMENT '产生方（下级/转介绍）',
  `order_no`      VARCHAR(64)   NOT NULL,
  `commission_type` VARCHAR(16) NOT NULL DEFAULT 'DISTRIBUTION' COMMENT 'DISTRIBUTION 分销 / REFERRAL 转介绍',
  `base_amount`   DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT '计佣基数',
  `rate`          DECIMAL(5,2)  NOT NULL DEFAULT 0.00 COMMENT '比例快照（落库留痕）',
  `amount`        DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `settle_status` VARCHAR(16)   NOT NULL DEFAULT 'PENDING' COMMENT 'PENDING/SETTLED/INVALID',
  `settle_no`     VARCHAR(64)            DEFAULT NULL,
  `create_time`   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time`   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted`       TINYINT       NOT NULL DEFAULT 0,
  `version`       INT           NOT NULL DEFAULT 0,
  `remark`        VARCHAR(255)           DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_commission_no` (`commission_no`),
  KEY `idx_commission_channel` (`channel_id`),
  KEY `idx_commission_order` (`order_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='佣金/返佣';

-- 对账 & 结算单
CREATE TABLE IF NOT EXISTS `t_settlement` (
  `id`              BIGINT        NOT NULL AUTO_INCREMENT,
  `settle_no`       VARCHAR(64)   NOT NULL,
  `channel_id`      BIGINT        NOT NULL,
  `period_start`    DATE          NOT NULL,
  `period_end`      DATE          NOT NULL,
  `order_amount`    DECIMAL(14,2) NOT NULL DEFAULT 0.00 COMMENT '期间订单额',
  `commission_amount` DECIMAL(14,2) NOT NULL DEFAULT 0.00 COMMENT '期间佣金',
  `settle_amount`   DECIMAL(14,2) NOT NULL DEFAULT 0.00 COMMENT '应结算金额',
  `status`          VARCHAR(16)   NOT NULL DEFAULT 'DRAFT' COMMENT 'DRAFT/CONFIRMED/PAID',
  `confirm_time`    DATETIME               DEFAULT NULL,
  `pay_time`        DATETIME               DEFAULT NULL,
  `create_time`     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time`     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted`         TINYINT       NOT NULL DEFAULT 0,
  `version`         INT           NOT NULL DEFAULT 0,
  `remark`          VARCHAR(255)           DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_settle_no` (`settle_no`),
  KEY `idx_settle_channel` (`channel_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='对账结算单';

-- 渠道额度变动（授信使用/回款）
CREATE TABLE IF NOT EXISTS `t_channel_quota_log` (
  `id`          BIGINT        NOT NULL AUTO_INCREMENT,
  `channel_id`  BIGINT        NOT NULL,
  `change_type` VARCHAR(16)   NOT NULL COMMENT 'OCCUPY/RELEASE/ADJUST',
  `amount`      DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  `before_quota` DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  `after_quota`  DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  `biz_no`      VARCHAR(64)            DEFAULT NULL,
  `create_time` DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted`     TINYINT       NOT NULL DEFAULT 0,
  `version`     INT           NOT NULL DEFAULT 0,
  `remark`      VARCHAR(255)           DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_quota_channel` (`channel_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='渠道额度流水';
