-- =============================================================
-- T02 建库：poyang_crab（字符集 utf8mb4）
-- 螃蟹小公主 · 鄱阳湖湖蟹 多端数字化平台
-- =============================================================

CREATE DATABASE IF NOT EXISTS `poyang_crab`
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_general_ci;

-- 本地开发账号（生产请使用独立强口令并通过环境变量注入）
CREATE USER IF NOT EXISTS 'poyang_crab'@'%' IDENTIFIED BY 'BZcEXmWxiDcmx5bw';
GRANT ALL PRIVILEGES ON `poyang_crab`.* TO 'poyang_crab'@'%';
FLUSH PRIVILEGES;

USE `poyang_crab`;

-- 全库统一 utf8mb4
ALTER DATABASE `poyang_crab` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
