-- =============================================================
-- T03 会员域 + 商品域（湖蟹规格 / SKU / 库存）
-- UnionID 贯通 公众号 / 小程序 / H5
-- =============================================================
USE `poyang_crab`;

-- 会员（UnionID 互通）
CREATE TABLE IF NOT EXISTS `member` (
  `id`            BIGINT       NOT NULL AUTO_INCREMENT,
  `union_id`      VARCHAR(64)           DEFAULT NULL COMMENT '微信 UnionID',
  `open_id_mp`    VARCHAR(64)           DEFAULT NULL COMMENT '公众号 openid',
  `open_id_mini`  VARCHAR(64)           DEFAULT NULL COMMENT '小程序 openid',
  `open_id_h5`    VARCHAR(64)           DEFAULT NULL COMMENT 'H5 openid',
  `nickname`      VARCHAR(64)           DEFAULT NULL,
  `avatar`        VARCHAR(512)          DEFAULT NULL,
  `mobile`        VARCHAR(20)           DEFAULT NULL,
  `gender`        TINYINT      NOT NULL DEFAULT 0,
  `member_level`  VARCHAR(32)  NOT NULL DEFAULT 'NORMAL',
  `points`        INT          NOT NULL DEFAULT 0 COMMENT '积分',
  `balance`       DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT '储值余额',
  `channel_id`    BIGINT                DEFAULT NULL COMMENT '归属渠道商（分销）',
  `status`        TINYINT      NOT NULL DEFAULT 1,
  `create_time`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted`       TINYINT      NOT NULL DEFAULT 0,
  `version`       INT          NOT NULL DEFAULT 0,
  `remark`        VARCHAR(255)          DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_member_union` (`union_id`),
  KEY `idx_member_mobile` (`mobile`),
  KEY `idx_member_channel` (`channel_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='会员';

CREATE TABLE IF NOT EXISTS `member_address` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT,
  `member_id`   BIGINT       NOT NULL,
  `contact`     VARCHAR(64)  NOT NULL,
  `mobile`      VARCHAR(20)  NOT NULL,
  `province`    VARCHAR(32)           DEFAULT NULL,
  `city`        VARCHAR(32)           DEFAULT NULL,
  `district`    VARCHAR(32)           DEFAULT NULL,
  `detail`      VARCHAR(255) NOT NULL,
  `is_default`  TINYINT      NOT NULL DEFAULT 0,
  `create_time` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted`     TINYINT      NOT NULL DEFAULT 0,
  `version`     INT          NOT NULL DEFAULT 0,
  `remark`      VARCHAR(255)          DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_addr_member` (`member_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='会员收货地址';

-- 积分流水
CREATE TABLE IF NOT EXISTS `member_point_log` (
  `id`          BIGINT      NOT NULL AUTO_INCREMENT,
  `member_id`   BIGINT      NOT NULL,
  `change_type` VARCHAR(16) NOT NULL COMMENT 'IN/OUT',
  `points`      INT         NOT NULL,
  `before_points` INT       NOT NULL DEFAULT 0,
  `after_points`  INT       NOT NULL DEFAULT 0,
  `source`      VARCHAR(32) NOT NULL COMMENT 'ORDER/SIGN/REFUND/ADMIN',
  `biz_no`      VARCHAR(64)          DEFAULT NULL,
  `create_time` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted`     TINYINT     NOT NULL DEFAULT 0,
  `version`     INT         NOT NULL DEFAULT 0,
  `remark`      VARCHAR(255)         DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_point_member` (`member_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='积分流水';

-- 储值流水
CREATE TABLE IF NOT EXISTS `member_balance_log` (
  `id`          BIGINT        NOT NULL AUTO_INCREMENT,
  `member_id`   BIGINT        NOT NULL,
  `change_type` VARCHAR(16)   NOT NULL COMMENT 'RECHARGE/CONSUME/REFUND/ADMIN',
  `amount`      DECIMAL(12,2) NOT NULL,
  `before_balance` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `after_balance`  DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `biz_no`      VARCHAR(64)            DEFAULT NULL,
  `create_time` DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted`     TINYINT       NOT NULL DEFAULT 0,
  `version`     INT           NOT NULL DEFAULT 0,
  `remark`      VARCHAR(255)           DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_balance_member` (`member_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='储值流水';

-- 卡券模板 + 领取记录
CREATE TABLE IF NOT EXISTS `member_coupon` (
  `id`            BIGINT        NOT NULL AUTO_INCREMENT,
  `coupon_name`   VARCHAR(64)   NOT NULL,
  `coupon_type`   VARCHAR(16)   NOT NULL DEFAULT 'DISCOUNT' COMMENT 'DISCOUNT/FULL_CUT/GIFT',
  `threshold`     DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT '门槛',
  `discount_amount` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `discount_rate` DECIMAL(5,2)  NOT NULL DEFAULT 10.00 COMMENT '折扣，如 8.50',
  `total_qty`     INT           NOT NULL DEFAULT 0,
  `used_qty`      INT           NOT NULL DEFAULT 0,
  `valid_start`   DATETIME               DEFAULT NULL,
  `valid_end`     DATETIME               DEFAULT NULL,
  `status`        TINYINT       NOT NULL DEFAULT 1,
  `create_time`   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time`   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted`       TINYINT       NOT NULL DEFAULT 0,
  `version`       INT           NOT NULL DEFAULT 0,
  `remark`        VARCHAR(255)           DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='卡券模板';

CREATE TABLE IF NOT EXISTS `member_coupon_log` (
  `id`          BIGINT      NOT NULL AUTO_INCREMENT,
  `coupon_id`   BIGINT      NOT NULL,
  `member_id`   BIGINT      NOT NULL,
  `status`      VARCHAR(16) NOT NULL DEFAULT 'UNUSED' COMMENT 'UNUSED/USED/EXPIRED',
  `order_no`    VARCHAR(64)          DEFAULT NULL,
  `used_time`   DATETIME             DEFAULT NULL,
  `create_time` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted`     TINYINT     NOT NULL DEFAULT 0,
  `version`     INT         NOT NULL DEFAULT 0,
  `remark`      VARCHAR(255)         DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_coupon_log_member` (`member_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='卡券领取/核销记录';

-- 商品分类
CREATE TABLE IF NOT EXISTS `product_category` (
  `id`          BIGINT      NOT NULL AUTO_INCREMENT,
  `parent_id`   BIGINT      NOT NULL DEFAULT 0,
  `category_name` VARCHAR(64) NOT NULL,
  `category_name_en` VARCHAR(64) DEFAULT NULL,
  `icon`        VARCHAR(512)         DEFAULT NULL,
  `sort`        INT         NOT NULL DEFAULT 0,
  `status`      TINYINT     NOT NULL DEFAULT 1,
  `create_time` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted`     TINYINT     NOT NULL DEFAULT 0,
  `version`     INT         NOT NULL DEFAULT 0,
  `remark`      VARCHAR(255)         DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_category_parent` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品分类';

-- 商品（湖蟹）
CREATE TABLE IF NOT EXISTS `product` (
  `id`            BIGINT        NOT NULL AUTO_INCREMENT,
  `product_no`    VARCHAR(64)   NOT NULL,
  `category_id`   BIGINT        NOT NULL,
  `product_name`  VARCHAR(128)  NOT NULL,
  `product_name_en` VARCHAR(128)         DEFAULT NULL,
  `main_image`    VARCHAR(512)           DEFAULT NULL,
  `images`        TEXT                   DEFAULT NULL COMMENT 'JSON 数组（图片上传组件产出）',
  `detail_html`   LONGTEXT               DEFAULT NULL COMMENT '富文本（多语言 tab）',
  `detail_html_en` LONGTEXT              DEFAULT NULL,
  `origin`        VARCHAR(128)  NOT NULL DEFAULT '鄱阳湖' COMMENT '产地',
  `sell_mode`     VARCHAR(16)   NOT NULL DEFAULT 'BOTH' COMMENT 'RETAIL/WHOLESALE/BOTH',
  `retail_price`  DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `wholesale_price` DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT '渠道专属批发价（后台可配置）',
  `min_order_qty` INT           NOT NULL DEFAULT 1 COMMENT '批发起订量，后台可配置',
  `live_room_id`  BIGINT                 DEFAULT NULL COMMENT '直播间关联',
  `seo_title`     VARCHAR(255)           DEFAULT NULL,
  `seo_keywords`  VARCHAR(255)           DEFAULT NULL,
  `seo_desc`      VARCHAR(512)           DEFAULT NULL,
  `status`        TINYINT       NOT NULL DEFAULT 1 COMMENT '1上架0下架',
  `sort`          INT           NOT NULL DEFAULT 0,
  `create_time`   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time`   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted`       TINYINT       NOT NULL DEFAULT 0,
  `version`       INT           NOT NULL DEFAULT 0,
  `remark`        VARCHAR(255)           DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_product_no` (`product_no`),
  KEY `idx_product_category` (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品（湖蟹）';

-- 湖蟹规格（公蟹/母蟹、重量档、只数礼盒）
CREATE TABLE IF NOT EXISTS `product_spec` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT,
  `product_id`  BIGINT       NOT NULL,
  `crab_sex`    VARCHAR(8)   NOT NULL DEFAULT 'MALE' COMMENT 'MALE/FEMALE/MIXED',
  `weight_level` VARCHAR(32) NOT NULL COMMENT '重量档，如 3.0-3.4两',
  `weight_min`  DECIMAL(6,2)          DEFAULT NULL COMMENT '两',
  `weight_max`  DECIMAL(6,2)          DEFAULT NULL,
  `piece_count` INT          NOT NULL DEFAULT 1 COMMENT '只数（礼盒）',
  `pack_type`   VARCHAR(32)  NOT NULL DEFAULT 'GIFT_BOX' COMMENT 'GIFT_BOX/LOOSE',
  `create_time` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted`     TINYINT      NOT NULL DEFAULT 0,
  `version`     INT          NOT NULL DEFAULT 0,
  `remark`      VARCHAR(255)          DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_spec_product` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='湖蟹规格';

-- SKU
CREATE TABLE IF NOT EXISTS `product_sku` (
  `id`            BIGINT        NOT NULL AUTO_INCREMENT,
  `product_id`    BIGINT        NOT NULL,
  `spec_id`       BIGINT                 DEFAULT NULL,
  `sku_no`        VARCHAR(64)   NOT NULL,
  `sku_name`      VARCHAR(128)  NOT NULL,
  `retail_price`  DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `wholesale_price` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `cost_price`    DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `image`         VARCHAR(512)           DEFAULT NULL,
  `status`        TINYINT       NOT NULL DEFAULT 1,
  `create_time`   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time`   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted`       TINYINT       NOT NULL DEFAULT 0,
  `version`       INT           NOT NULL DEFAULT 0,
  `remark`        VARCHAR(255)           DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_sku_no` (`sku_no`),
  KEY `idx_sku_product` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品 SKU';

-- 库存（自营 + 批发共用；含锁定库存）
CREATE TABLE IF NOT EXISTS `stock` (
  `id`            BIGINT      NOT NULL AUTO_INCREMENT,
  `sku_id`        BIGINT      NOT NULL,
  `warehouse`     VARCHAR(64) NOT NULL DEFAULT 'MAIN' COMMENT '仓库/冷链中转',
  `total_qty`     INT         NOT NULL DEFAULT 0,
  `available_qty` INT         NOT NULL DEFAULT 0,
  `locked_qty`    INT         NOT NULL DEFAULT 0 COMMENT '下单未支付锁定',
  `warn_qty`      INT         NOT NULL DEFAULT 0 COMMENT '预警值',
  `create_time`   DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time`   DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted`       TINYINT     NOT NULL DEFAULT 0,
  `version`       INT         NOT NULL DEFAULT 0,
  `remark`        VARCHAR(255)         DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_stock_sku_wh` (`sku_id`,`warehouse`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='库存（共用于自营+批发）';

CREATE TABLE IF NOT EXISTS `stock_log` (
  `id`          BIGINT      NOT NULL AUTO_INCREMENT,
  `sku_id`      BIGINT      NOT NULL,
  `warehouse`   VARCHAR(64) NOT NULL DEFAULT 'MAIN',
  `change_type` VARCHAR(16) NOT NULL COMMENT 'IN/OUT/LOCK/UNLOCK',
  `qty`         INT         NOT NULL,
  `biz_type`    VARCHAR(32)          DEFAULT NULL COMMENT 'ORDER/SHIP/REFUND/ADMIN',
  `biz_no`      VARCHAR(64)          DEFAULT NULL,
  `create_time` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted`     TINYINT     NOT NULL DEFAULT 0,
  `version`     INT         NOT NULL DEFAULT 0,
  `remark`      VARCHAR(255)         DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_stock_log_sku` (`sku_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='库存流水';

-- 购物车（Redis 为主，此处持久化兜底）
CREATE TABLE IF NOT EXISTS `cart` (
  `id`          BIGINT      NOT NULL AUTO_INCREMENT,
  `member_id`   BIGINT      NOT NULL,
  `sku_id`      BIGINT      NOT NULL,
  `qty`         INT         NOT NULL DEFAULT 1,
  `checked`     TINYINT     NOT NULL DEFAULT 1,
  `create_time` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted`     TINYINT     NOT NULL DEFAULT 0,
  `version`     INT         NOT NULL DEFAULT 0,
  `remark`      VARCHAR(255)         DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_cart_member` (`member_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='购物车';

-- 直播间关联
CREATE TABLE IF NOT EXISTS `live_room` (
  `id`          BIGINT      NOT NULL AUTO_INCREMENT,
  `room_name`   VARCHAR(128) NOT NULL,
  `platform`    VARCHAR(16) NOT NULL DEFAULT 'DOUYIN' COMMENT 'DOUYIN/WECHAT/OTHER',
  `room_no`     VARCHAR(64)          DEFAULT NULL,
  `anchor`      VARCHAR(64)          DEFAULT NULL,
  `cover`       VARCHAR(512)         DEFAULT NULL,
  `replay_url`  VARCHAR(1024)        DEFAULT NULL,
  `live_status` TINYINT     NOT NULL DEFAULT 0 COMMENT '0预告1直播中2回放',
  `start_time`  DATETIME             DEFAULT NULL,
  `end_time`    DATETIME             DEFAULT NULL,
  `create_time` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted`     TINYINT     NOT NULL DEFAULT 0,
  `version`     INT         NOT NULL DEFAULT 0,
  `remark`      VARCHAR(255)         DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='直播间';
