-- =============================================================
-- T03 交易域：订单 / 明细 / 支付流水 / 冷链物流 / 评价
-- 核心流程：全款在线下单 → 微信支付 → 冷链发货 → 物流 → 评价
-- =============================================================
USE `poyang_crab`;

CREATE TABLE IF NOT EXISTS `t_order` (
  `id`              BIGINT        NOT NULL AUTO_INCREMENT,
  `order_no`        VARCHAR(64)   NOT NULL,
  `member_id`       BIGINT        NOT NULL,
  `biz_mode`        VARCHAR(16)   NOT NULL DEFAULT 'RETAIL' COMMENT 'RETAIL 自营 / WHOLESALE 批发',
  `channel_id`      BIGINT                 DEFAULT NULL COMMENT '批发归属渠道商',
  `order_status`    VARCHAR(24)   NOT NULL DEFAULT 'UNPAID'
                    COMMENT 'UNPAID/PAID/SORTING/PACKED/SHIPPED/RECEIVED/COMPLETED/CANCELLED/REFUNDING/REFUNDED',
  `pay_status`      VARCHAR(16)   NOT NULL DEFAULT 'UNPAID' COMMENT 'UNPAID/PAID/REFUNDED',
  `total_amount`    DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `discount_amount` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `freight_amount`  DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT '冷链运费',
  `pay_amount`      DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `coupon_id`       BIGINT                 DEFAULT NULL,
  `pay_type`        VARCHAR(16)            DEFAULT NULL COMMENT 'WECHAT/ALIPAY/BALANCE',
  `pay_time`        DATETIME               DEFAULT NULL,
  `receiver_name`   VARCHAR(64)            DEFAULT NULL,
  `receiver_mobile` VARCHAR(20)            DEFAULT NULL,
  `receiver_address` VARCHAR(512)          DEFAULT NULL,
  `remark`          VARCHAR(255)           DEFAULT NULL,
  `expire_time`     DATETIME               DEFAULT NULL COMMENT '未支付超时时间（延迟队列）',
  `cancel_reason`   VARCHAR(255)           DEFAULT NULL,
  `source`          VARCHAR(16)   NOT NULL DEFAULT 'MINIAPP' COMMENT 'MINIAPP/H5/PC/ADMIN/CHANNEL',
  `create_time`     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time`     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted`         TINYINT       NOT NULL DEFAULT 0,
  `version`         INT           NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_order_no` (`order_no`),
  KEY `idx_order_member` (`member_id`),
  KEY `idx_order_status` (`order_status`),
  KEY `idx_order_channel` (`channel_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单（自营+批发）';

CREATE TABLE IF NOT EXISTS `t_order_item` (
  `id`          BIGINT        NOT NULL AUTO_INCREMENT,
  `order_no`    VARCHAR(64)   NOT NULL,
  `order_id`    BIGINT        NOT NULL,
  `product_id`  BIGINT        NOT NULL,
  `sku_id`      BIGINT        NOT NULL,
  `product_name` VARCHAR(128) NOT NULL,
  `sku_name`    VARCHAR(128)  NOT NULL,
  `spec_desc`   VARCHAR(128)           DEFAULT NULL COMMENT '公母/重量档/只数',
  `price`       DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `qty`         INT           NOT NULL DEFAULT 1,
  `amount`      DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `image`       VARCHAR(512)           DEFAULT NULL,
  `create_time` DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted`     TINYINT       NOT NULL DEFAULT 0,
  `version`     INT           NOT NULL DEFAULT 0,
  `remark`      VARCHAR(255)           DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_order_item_order` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单明细';

-- 支付流水（微信支付 / 支付宝）
CREATE TABLE IF NOT EXISTS `t_payment` (
  `id`              BIGINT        NOT NULL AUTO_INCREMENT,
  `pay_no`          VARCHAR(64)   NOT NULL COMMENT '平台支付单号',
  `order_no`        VARCHAR(64)   NOT NULL,
  `pay_type`        VARCHAR(16)   NOT NULL COMMENT 'WECHAT/ALIPAY/BALANCE',
  `trade_no`        VARCHAR(128)           DEFAULT NULL COMMENT '第三方交易号',
  `amount`          DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `pay_status`      VARCHAR(16)   NOT NULL DEFAULT 'UNPAID' COMMENT 'UNPAID/SUCCESS/FAIL/REFUND',
  `notify_raw`      TEXT                   DEFAULT NULL COMMENT '回调原文',
  `refund_amount`   DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `pay_time`        DATETIME               DEFAULT NULL,
  `create_time`     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time`     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted`         TINYINT       NOT NULL DEFAULT 0,
  `version`         INT           NOT NULL DEFAULT 0,
  `remark`          VARCHAR(255)           DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_pay_no` (`pay_no`),
  KEY `idx_payment_order` (`order_no`),
  UNIQUE KEY `uk_payment_trade` (`pay_type`,`trade_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='支付流水';

-- 冷链物流（顺丰，含轨迹）
CREATE TABLE IF NOT EXISTS `t_order_delivery` (
  `id`            BIGINT       NOT NULL AUTO_INCREMENT,
  `order_no`      VARCHAR(64)  NOT NULL,
  `express_company` VARCHAR(32) NOT NULL DEFAULT 'SF' COMMENT '顺丰冷链',
  `express_no`    VARCHAR(64)           DEFAULT NULL COMMENT '运单号',
  `cold_chain`    TINYINT      NOT NULL DEFAULT 1 COMMENT '是否冷链',
  `pack_check`    VARCHAR(512)          DEFAULT NULL COMMENT '鲜活打包核验结果（公母/重量）',
  `packer_id`     BIGINT                DEFAULT NULL COMMENT '打包/发货员',
  `ship_status`   VARCHAR(24)  NOT NULL DEFAULT 'WAIT'
                  COMMENT 'WAIT/SORTING/PACKED/OUTBOUND/SHIPPED/IN_TRANSIT/SIGNED/EXCEPTION',
  `track_json`    TEXT                  DEFAULT NULL COMMENT '顺丰轨迹缓存',
  `express_print_time` DATETIME         DEFAULT NULL COMMENT '快递单打印时间',
  `outbound_time` DATETIME              DEFAULT NULL,
  `ship_time`     DATETIME              DEFAULT NULL,
  `signed_time`   DATETIME              DEFAULT NULL,
  `create_time`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted`       TINYINT      NOT NULL DEFAULT 0,
  `version`       INT          NOT NULL DEFAULT 0,
  `remark`        VARCHAR(255)          DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_delivery_order` (`order_no`),
  KEY `idx_delivery_express` (`express_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='冷链物流';

-- 收货评价
CREATE TABLE IF NOT EXISTS `t_review` (
  `id`          BIGINT      NOT NULL AUTO_INCREMENT,
  `order_no`    VARCHAR(64) NOT NULL,
  `member_id`   BIGINT      NOT NULL,
  `product_id`  BIGINT      NOT NULL,
  `sku_id`      BIGINT               DEFAULT NULL,
  `score`       TINYINT     NOT NULL DEFAULT 5 COMMENT '1-5',
  `content`     VARCHAR(1024)        DEFAULT NULL COMMENT '敏感词过滤',
  `images`      TEXT                 DEFAULT NULL,
  `survival_rate` TINYINT            DEFAULT NULL COMMENT '鲜活度（1-5）',
  `is_show`     TINYINT     NOT NULL DEFAULT 0,
  `reply_content` VARCHAR(1024)      DEFAULT NULL,
  `create_time` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted`     TINYINT     NOT NULL DEFAULT 0,
  `version`     INT         NOT NULL DEFAULT 0,
  `remark`      VARCHAR(255)         DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_review_order` (`order_no`),
  KEY `idx_review_product` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='收货评价';
