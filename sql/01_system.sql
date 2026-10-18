-- =============================================================
-- T03 系统域：用户 / RBAC / 参数 / 菜单 / 多语言 / 审计 / 存储
-- 公共字段：create_time update_time deleted version（BaseEntity）
-- =============================================================
USE `poyang_crab`;

-- 后台用户
CREATE TABLE IF NOT EXISTS `sys_user` (
  `id`           BIGINT       NOT NULL AUTO_INCREMENT,
  `username`     VARCHAR(64)  NOT NULL COMMENT '登录名',
  `password`     VARCHAR(128) NOT NULL COMMENT 'BCrypt 密文',
  `real_name`    VARCHAR(64)           DEFAULT NULL,
  `mobile`       VARCHAR(20)           DEFAULT NULL,
  `avatar`       VARCHAR(512)          DEFAULT NULL,
  `role_type`    VARCHAR(32)  NOT NULL DEFAULT 'ADMIN' COMMENT '超级管理员/店长/财务/仓管发货员/渠道商管理员',
  `channel_id`   BIGINT                DEFAULT NULL COMMENT '渠道商用户归属渠道',
  `status`       TINYINT      NOT NULL DEFAULT 1 COMMENT '1启用0禁用',
  `last_login_at` DATETIME             DEFAULT NULL,
  `create_time`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted`      TINYINT      NOT NULL DEFAULT 0,
  `version`      INT          NOT NULL DEFAULT 0,
  `remark`       VARCHAR(255)          DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_sys_user_username` (`username`),
  KEY `idx_sys_user_channel` (`channel_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='后台用户';

-- 角色
CREATE TABLE IF NOT EXISTS `sys_role` (
  `id`          BIGINT      NOT NULL AUTO_INCREMENT,
  `role_code`   VARCHAR(64) NOT NULL COMMENT 'MEMBER/SUPER_ADMIN/SHOP_MANAGER/FINANCE/SHIPPER/CHANNEL/CHANNEL_ADMIN',
  `role_name`   VARCHAR(64) NOT NULL,
  `data_scope`  VARCHAR(16) NOT NULL DEFAULT 'ALL' COMMENT 'ALL/SELF/CHANNEL',
  `sort`        INT         NOT NULL DEFAULT 0,
  `status`      TINYINT     NOT NULL DEFAULT 1,
  `create_time` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted`     TINYINT     NOT NULL DEFAULT 0,
  `version`     INT         NOT NULL DEFAULT 0,
  `remark`      VARCHAR(255)         DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_sys_role_code` (`role_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='RBAC 角色';

CREATE TABLE IF NOT EXISTS `sys_user_role` (
  `id`      BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL,
  `role_id` BIGINT NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_role` (`user_id`,`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户-角色';

-- 菜单（PC 导航 / 公众号菜单 / 小程序 tabBar / H5 底部导航 统一维护）
CREATE TABLE IF NOT EXISTS `sys_menu` (
  `id`            BIGINT       NOT NULL AUTO_INCREMENT,
  `parent_id`     BIGINT       NOT NULL DEFAULT 0,
  `menu_name`     VARCHAR(64)  NOT NULL,
  `platform`      VARCHAR(16)  NOT NULL DEFAULT 'ADMIN' COMMENT 'ADMIN/PC/WECHAT_MP/MINIAPP/H5',
  `menu_type`     VARCHAR(16)  NOT NULL DEFAULT 'MENU' COMMENT 'DIR/MENU/BUTTON',
  `link_type`     VARCHAR(16)  NOT NULL DEFAULT 'INNER' COMMENT 'INNER/OUTER/MINIAPP',
  `path`          VARCHAR(255)          DEFAULT NULL,
  `component`     VARCHAR(255)          DEFAULT NULL,
  `icon`          VARCHAR(64)           DEFAULT NULL,
  `perm`          VARCHAR(128)          DEFAULT NULL COMMENT '权限标识，如 product:edit',
  `sort`          INT          NOT NULL DEFAULT 0,
  `visible`       TINYINT      NOT NULL DEFAULT 1,
  `keep_alive`    TINYINT      NOT NULL DEFAULT 1,
  `wx_publish_status` TINYINT NOT NULL DEFAULT 0 COMMENT '公众号菜单：0未发布1已发布',
  `create_time`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted`       TINYINT      NOT NULL DEFAULT 0,
  `version`       INT          NOT NULL DEFAULT 0,
  `remark`        VARCHAR(255)          DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_sys_menu_parent` (`parent_id`),
  KEY `idx_sys_menu_platform` (`platform`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='菜单/导航（多端）';

CREATE TABLE IF NOT EXISTS `sys_role_menu` (
  `id`      BIGINT NOT NULL AUTO_INCREMENT,
  `role_id` BIGINT NOT NULL,
  `menu_id` BIGINT NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_role_menu` (`role_id`,`menu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色-菜单';

-- 系统全局参数（站点/ICP/客服/微信/支付/存储），金额与比例一律走此表，禁止写死
CREATE TABLE IF NOT EXISTS `sys_config` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT,
  `config_key`  VARCHAR(128) NOT NULL,
  `config_name` VARCHAR(128) NOT NULL,
  `config_group` VARCHAR(32) NOT NULL DEFAULT 'SITE' COMMENT 'SITE/ICP/SERVICE/WECHAT/PAY/STORAGE/BUSINESS',
  `config_value` TEXT                 DEFAULT NULL,
  `value_type`  VARCHAR(16)  NOT NULL DEFAULT 'STRING' COMMENT 'STRING/NUMBER/BOOL/JSON',
  `is_encrypted` TINYINT     NOT NULL DEFAULT 0 COMMENT '1 表示密文（AK/SK 等）',
  `editable`    TINYINT      NOT NULL DEFAULT 1,
  `sort`        INT          NOT NULL DEFAULT 0,
  `create_time` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted`     TINYINT      NOT NULL DEFAULT 0,
  `version`     INT          NOT NULL DEFAULT 0,
  `remark`      VARCHAR(255)          DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_sys_config_key` (`config_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统全局参数';

-- 字典
CREATE TABLE IF NOT EXISTS `sys_dict` (
  `id`          BIGINT      NOT NULL AUTO_INCREMENT,
  `dict_type`   VARCHAR(64) NOT NULL,
  `dict_name`   VARCHAR(64) NOT NULL,
  `create_time` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted`     TINYINT     NOT NULL DEFAULT 0,
  `version`     INT         NOT NULL DEFAULT 0,
  `remark`      VARCHAR(255)         DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_sys_dict_type` (`dict_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='字典类型';

CREATE TABLE IF NOT EXISTS `sys_dict_item` (
  `id`          BIGINT      NOT NULL AUTO_INCREMENT,
  `dict_type`   VARCHAR(64) NOT NULL,
  `item_label`  VARCHAR(64) NOT NULL,
  `item_value`  VARCHAR(64) NOT NULL,
  `sort`        INT         NOT NULL DEFAULT 0,
  `status`      TINYINT     NOT NULL DEFAULT 1,
  `create_time` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted`     TINYINT     NOT NULL DEFAULT 0,
  `version`     INT         NOT NULL DEFAULT 0,
  `remark`      VARCHAR(255)         DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_dict_item_type` (`dict_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='字典项';

-- 多语言：语言列表 + 词条
CREATE TABLE IF NOT EXISTS `sys_lang` (
  `id`          BIGINT      NOT NULL AUTO_INCREMENT,
  `lang_code`   VARCHAR(16) NOT NULL COMMENT 'zh-CN / en-US',
  `lang_name`   VARCHAR(64) NOT NULL,
  `is_default`  TINYINT     NOT NULL DEFAULT 0,
  `status`      TINYINT     NOT NULL DEFAULT 1,
  `sort`        INT         NOT NULL DEFAULT 0,
  `create_time` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted`     TINYINT     NOT NULL DEFAULT 0,
  `version`     INT         NOT NULL DEFAULT 0,
  `remark`      VARCHAR(255)         DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_sys_lang_code` (`lang_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='语言列表';

CREATE TABLE IF NOT EXISTS `sys_i18n` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT,
  `item_key`    VARCHAR(128) NOT NULL COMMENT '词条键，如 home.title',
  `lang_code`   VARCHAR(16)  NOT NULL,
  `item_value`  TEXT                  DEFAULT NULL,
  `create_time` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted`     TINYINT      NOT NULL DEFAULT 0,
  `version`     INT          NOT NULL DEFAULT 0,
  `remark`      VARCHAR(255)          DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_i18n_key_lang` (`item_key`,`lang_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='多语言词条';

-- 审计日志（只读，禁止增删改）
CREATE TABLE IF NOT EXISTS `sys_audit_log` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT,
  `user_id`     BIGINT                DEFAULT NULL,
  `username`    VARCHAR(64)           DEFAULT NULL,
  `module`      VARCHAR(64)           DEFAULT NULL,
  `operation`   VARCHAR(64)           DEFAULT NULL COMMENT 'CREATE/UPDATE/DELETE/QUERY/LOGIN/PUBLISH',
  `method`      VARCHAR(255)          DEFAULT NULL,
  `request_uri` VARCHAR(512)          DEFAULT NULL,
  `request_param` TEXT                DEFAULT NULL,
  `ip`          VARCHAR(64)           DEFAULT NULL,
  `user_agent`  VARCHAR(512)          DEFAULT NULL,
  `success`     TINYINT      NOT NULL DEFAULT 1,
  `error_msg`   VARCHAR(1024)         DEFAULT NULL,
  `cost_ms`     BIGINT                DEFAULT NULL,
  `create_time` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_audit_user` (`user_id`),
  KEY `idx_audit_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='全操作审计日志（只读）';

-- 对象存储配置（5 驱动；密钥加密落库）
CREATE TABLE IF NOT EXISTS `sys_storage_config` (
  `id`            BIGINT      NOT NULL AUTO_INCREMENT,
  `driver`        VARCHAR(16) NOT NULL COMMENT 'LOCAL/S3/OSS/COS/MINIO',
  `config_json`   TEXT                 DEFAULT NULL COMMENT '驱动参数（AK/SK 密文）',
  `is_active`     TINYINT     NOT NULL DEFAULT 0,
  `test_passed`   TINYINT     NOT NULL DEFAULT 0 COMMENT '连接测试通过才允许启用',
  `test_time`     DATETIME             DEFAULT NULL,
  `create_time`   DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time`   DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted`       TINYINT     NOT NULL DEFAULT 0,
  `version`       INT         NOT NULL DEFAULT 0,
  `remark`        VARCHAR(255)         DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_storage_driver` (`driver`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='对象存储配置';

-- 文件记录
CREATE TABLE IF NOT EXISTS `sys_file` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT,
  `driver`      VARCHAR(16)  NOT NULL,
  `bucket`      VARCHAR(128)          DEFAULT NULL,
  `object_key`  VARCHAR(512) NOT NULL,
  `url`         VARCHAR(1024) NOT NULL,
  `origin_name` VARCHAR(255)          DEFAULT NULL,
  `file_size`   BIGINT                DEFAULT NULL,
  `content_type` VARCHAR(128)         DEFAULT NULL,
  `biz_type`    VARCHAR(64)           DEFAULT NULL,
  `create_time` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted`     TINYINT      NOT NULL DEFAULT 0,
  `version`     INT          NOT NULL DEFAULT 0,
  `remark`      VARCHAR(255)          DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_sys_file_biz` (`biz_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='文件记录';

-- 敏感词
CREATE TABLE IF NOT EXISTS `sys_sensitive_word` (
  `id`          BIGINT      NOT NULL AUTO_INCREMENT,
  `word`        VARCHAR(64) NOT NULL,
  `level`       TINYINT     NOT NULL DEFAULT 1 COMMENT '1替换2拦截',
  `create_time` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted`     TINYINT     NOT NULL DEFAULT 0,
  `version`     INT         NOT NULL DEFAULT 0,
  `remark`      VARCHAR(255)         DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_sensitive_word` (`word`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='敏感词';
