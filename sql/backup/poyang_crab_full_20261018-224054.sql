-- MySQL dump 10.13  Distrib 8.0.29, for Win64 (x86_64)
--
-- Host: localhost    Database: poyang_crab
-- ------------------------------------------------------
-- Server version	8.0.29

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `cart`
--

DROP TABLE IF EXISTS `cart`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cart` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `member_id` bigint NOT NULL,
  `sku_id` bigint NOT NULL,
  `qty` int NOT NULL DEFAULT '1',
  `checked` tinyint NOT NULL DEFAULT '1',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  `version` int NOT NULL DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_cart_member` (`member_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='购物车';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cart`
--

LOCK TABLES `cart` WRITE;
/*!40000 ALTER TABLE `cart` DISABLE KEYS */;
/*!40000 ALTER TABLE `cart` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cms_article`
--

DROP TABLE IF EXISTS `cms_article`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cms_article` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `category_id` bigint NOT NULL,
  `title` varchar(255) NOT NULL,
  `title_en` varchar(255) DEFAULT NULL,
  `summary` varchar(512) DEFAULT NULL,
  `summary_en` varchar(512) DEFAULT NULL,
  `cover` varchar(512) DEFAULT NULL,
  `content_html` longtext COMMENT '富文本（中文 tab）',
  `content_html_en` longtext COMMENT '富文本（英文 tab）',
  `seo_title` varchar(255) DEFAULT NULL,
  `seo_keywords` varchar(255) DEFAULT NULL,
  `seo_desc` varchar(512) DEFAULT NULL,
  `is_top` tinyint NOT NULL DEFAULT '0',
  `status` varchar(16) NOT NULL DEFAULT 'DRAFT' COMMENT 'DRAFT/PUBLISHED',
  `publish_time` datetime DEFAULT NULL,
  `view_count` int NOT NULL DEFAULT '0',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  `version` int NOT NULL DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_article_category` (`category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='CMS 文章';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cms_article`
--

LOCK TABLES `cms_article` WRITE;
/*!40000 ALTER TABLE `cms_article` DISABLE KEYS */;
INSERT INTO `cms_article` VALUES (1,1,'鄱阳湖大闸蟹的四季：从投苗到上桌','Four Seasons of Poyang Lake Hairy Crab','从春天投苗、夏天喂螺蛳，到秋天膏满黄肥，记录一只鄱阳湖大闸蟹的完整生长周期。','From spring seeding to autumn harvest, the full growth cycle of Poyang Lake hairy crab.','','<h3>春季投苗</h3><p>三月水温回升，湖区开始投放蟹苗，选用长江水系优质扣蟹。</p><h3>秋季膏黄</h3><p>九月末至十一月是鄱阳湖大闸蟹的最佳赏味期，公蟹膏腴、母蟹黄满。</p>','<h3>Spring</h3><p>Seeding begins when water temperature rises in March.</p><h3>Autumn</h3><p>Late September to November is the best season.</p>','鄱阳湖大闸蟹的四季 · 螃蟹小公主','鄱阳湖,大闸蟹,养殖,礼盒','鄱阳湖大闸蟹生长周期与最佳赏味期科普。',1,'PUBLISHED','2026-10-08 09:00:00',1286,'2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL),(2,3,'凌晨四点的捕捞实景：一网湖蟹如何上岸','Harvest at 4 A.M. on Poyang Lake','跟随捕捞队出湖，记录从起网、分拣、暂养到装车冷链的全过程。','Follow the harvest team and see how crabs are netted, sorted and cold-chain shipped.','','<h3>起网</h3><p>凌晨四点，捕捞船在核心湖区起网，湖蟹即刻进入分拣筐。</p><h3>暂养与分拣</h3><p>上岸后按公母与重量档快速分拣，两小时内完成暂养并装箱。</p>','<h3>Netting</h3><p>Crews net crabs at 4 a.m. in the core lake area.</p><h3>Sorting</h3><p>Crabs are sorted by sex and weight within two hours.</p>','鄱阳湖捕捞实景 · 螃蟹小公主','鄱阳湖,捕捞,分拣,冷链','凌晨捕捞与冷链直发的现场记录。',0,'PUBLISHED','2026-10-12 08:30:00',642,'2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL),(3,5,'平台公告：2026 年蟹季售后与鲜活保障说明','Notice: 2026 Season Freshness Guarantee','蟹季售后细则、死蟹赔付标准与冷链时效说明（草稿待发布）。','After-sales rules and freshness compensation policy (draft).','','<p>本公告为草稿，待运营确认后发布。</p>','','平台公告 · 螃蟹小公主','售后,赔付,冷链','蟹季售后与鲜活保障说明。',0,'DRAFT',NULL,0,'2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL);
/*!40000 ALTER TABLE `cms_article` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cms_category`
--

DROP TABLE IF EXISTS `cms_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cms_category` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `parent_id` bigint NOT NULL DEFAULT '0',
  `category_name` varchar(64) NOT NULL,
  `category_name_en` varchar(64) DEFAULT NULL,
  `category_code` varchar(64) NOT NULL COMMENT 'brand/base/catch/recruit/notice',
  `sort` int NOT NULL DEFAULT '0',
  `status` tinyint NOT NULL DEFAULT '1',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  `version` int NOT NULL DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_cms_category_code` (`category_code`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='CMS 栏目';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cms_category`
--

LOCK TABLES `cms_category` WRITE;
/*!40000 ALTER TABLE `cms_category` DISABLE KEYS */;
INSERT INTO `cms_category` VALUES (1,0,'品牌故事','Brand Story','brand',1,1,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL),(2,0,'养殖基地','Farming Base','base',2,1,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL),(3,0,'捕捞实景','Harvest Scene','catch',3,1,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL),(4,0,'招商合作','Partnership','recruit',4,1,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL),(5,0,'平台公告','Notice','notice',5,1,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL),(6,0,'联调冒烟栏目-已改',NULL,'SMOKE_TEST',98,1,'2026-10-18 17:42:22','2026-10-18 17:42:22',1,0,NULL);
/*!40000 ALTER TABLE `cms_category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cms_channel_apply`
--

DROP TABLE IF EXISTS `cms_channel_apply`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cms_channel_apply` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `company_name` varchar(128) NOT NULL,
  `contact_name` varchar(64) NOT NULL,
  `contact_mobile` varchar(20) NOT NULL,
  `region` varchar(128) DEFAULT NULL,
  `intention` varchar(1024) DEFAULT NULL,
  `audit_status` varchar(16) NOT NULL DEFAULT 'PENDING' COMMENT 'PENDING/APPROVED/REJECTED',
  `audit_remark` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  `version` int NOT NULL DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='渠道商申请';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cms_channel_apply`
--

LOCK TABLES `cms_channel_apply` WRITE;
/*!40000 ALTER TABLE `cms_channel_apply` DISABLE KEYS */;
INSERT INTO `cms_channel_apply` VALUES (1,'南昌蟹逅商贸有限公司','王经理','13900000001','江西省南昌市','区域独家分销，年采购量约 5000 斤','PENDING',NULL,'2026-10-18 20:54:08','2026-10-18 20:54:08',0,0,NULL);
/*!40000 ALTER TABLE `cms_channel_apply` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `live_room`
--

DROP TABLE IF EXISTS `live_room`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `live_room` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `room_name` varchar(128) NOT NULL,
  `platform` varchar(16) NOT NULL DEFAULT 'DOUYIN' COMMENT 'DOUYIN/WECHAT/OTHER',
  `room_no` varchar(64) DEFAULT NULL,
  `anchor` varchar(64) DEFAULT NULL,
  `cover` varchar(512) DEFAULT NULL,
  `replay_url` varchar(1024) DEFAULT NULL,
  `live_status` tinyint NOT NULL DEFAULT '0' COMMENT '0预告1直播中2回放',
  `start_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  `version` int NOT NULL DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='直播间';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `live_room`
--

LOCK TABLES `live_room` WRITE;
/*!40000 ALTER TABLE `live_room` DISABLE KEYS */;
/*!40000 ALTER TABLE `live_room` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `member`
--

DROP TABLE IF EXISTS `member`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `member` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `union_id` varchar(64) DEFAULT NULL COMMENT '微信 UnionID',
  `open_id_mp` varchar(64) DEFAULT NULL COMMENT '公众号 openid',
  `open_id_mini` varchar(64) DEFAULT NULL COMMENT '小程序 openid',
  `open_id_h5` varchar(64) DEFAULT NULL COMMENT 'H5 openid',
  `nickname` varchar(64) DEFAULT NULL,
  `avatar` varchar(512) DEFAULT NULL,
  `mobile` varchar(20) DEFAULT NULL,
  `gender` tinyint NOT NULL DEFAULT '0',
  `member_level` varchar(32) NOT NULL DEFAULT 'NORMAL',
  `points` int NOT NULL DEFAULT '0' COMMENT '积分',
  `balance` decimal(12,2) NOT NULL DEFAULT '0.00' COMMENT '储值余额',
  `channel_id` bigint DEFAULT NULL COMMENT '归属渠道商（分销）',
  `status` tinyint NOT NULL DEFAULT '1',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  `version` int NOT NULL DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_member_union` (`union_id`),
  KEY `idx_member_mobile` (`mobile`),
  KEY `idx_member_channel` (`channel_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='会员';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `member`
--

LOCK TABLES `member` WRITE;
/*!40000 ALTER TABLE `member` DISABLE KEYS */;
INSERT INTO `member` VALUES (1,'oU_demo_union_001',NULL,'oMini_demo_001',NULL,'鄱阳湖畔的吃货',NULL,'13800000001',1,'GOLD',1280,200.00,NULL,1,'2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL),(2,'oU_demo_union_002',NULL,'oMini_demo_002',NULL,'蟹老板',NULL,'13800000002',1,'NORMAL',120,0.00,NULL,1,'2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL),(3,'oU_demo_union_003',NULL,'oMini_demo_003',NULL,'老表张三',NULL,'13800000003',2,'SILVER',560,50.00,NULL,1,'2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL);
/*!40000 ALTER TABLE `member` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `member_address`
--

DROP TABLE IF EXISTS `member_address`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `member_address` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `member_id` bigint NOT NULL,
  `contact` varchar(64) NOT NULL,
  `mobile` varchar(20) NOT NULL,
  `province` varchar(32) DEFAULT NULL,
  `city` varchar(32) DEFAULT NULL,
  `district` varchar(32) DEFAULT NULL,
  `detail` varchar(255) NOT NULL,
  `is_default` tinyint NOT NULL DEFAULT '0',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  `version` int NOT NULL DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_addr_member` (`member_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='会员收货地址';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `member_address`
--

LOCK TABLES `member_address` WRITE;
/*!40000 ALTER TABLE `member_address` DISABLE KEYS */;
/*!40000 ALTER TABLE `member_address` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `member_balance_log`
--

DROP TABLE IF EXISTS `member_balance_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `member_balance_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `member_id` bigint NOT NULL,
  `change_type` varchar(16) NOT NULL COMMENT 'RECHARGE/CONSUME/REFUND/ADMIN',
  `amount` decimal(12,2) NOT NULL,
  `before_balance` decimal(12,2) NOT NULL DEFAULT '0.00',
  `after_balance` decimal(12,2) NOT NULL DEFAULT '0.00',
  `biz_no` varchar(64) DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  `version` int NOT NULL DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_balance_member` (`member_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='储值流水';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `member_balance_log`
--

LOCK TABLES `member_balance_log` WRITE;
/*!40000 ALTER TABLE `member_balance_log` DISABLE KEYS */;
INSERT INTO `member_balance_log` VALUES (1,1,'EARN',200.00,0.00,200.00,'RECHARGE20261001','2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL),(2,3,'EARN',50.00,0.00,50.00,'RECHARGE20261002','2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL);
/*!40000 ALTER TABLE `member_balance_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `member_coupon`
--

DROP TABLE IF EXISTS `member_coupon`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `member_coupon` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `coupon_name` varchar(64) NOT NULL,
  `coupon_type` varchar(16) NOT NULL DEFAULT 'DISCOUNT' COMMENT 'DISCOUNT/FULL_CUT/GIFT',
  `threshold` decimal(12,2) NOT NULL DEFAULT '0.00' COMMENT '门槛',
  `discount_amount` decimal(12,2) NOT NULL DEFAULT '0.00',
  `discount_rate` decimal(5,2) NOT NULL DEFAULT '10.00' COMMENT '折扣，如 8.50',
  `total_qty` int NOT NULL DEFAULT '0',
  `used_qty` int NOT NULL DEFAULT '0',
  `valid_start` datetime DEFAULT NULL,
  `valid_end` datetime DEFAULT NULL,
  `status` tinyint NOT NULL DEFAULT '1',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  `version` int NOT NULL DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='卡券模板';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `member_coupon`
--

LOCK TABLES `member_coupon` WRITE;
/*!40000 ALTER TABLE `member_coupon` DISABLE KEYS */;
INSERT INTO `member_coupon` VALUES (1,'新客立减 20 元','CASH',199.00,20.00,0.00,1000,156,'2026-09-01 00:00:00','2026-12-31 23:59:59',1,'2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL),(2,'礼盒专享 9 折','DISCOUNT',500.00,0.00,90.00,500,88,'2026-09-15 00:00:00','2026-10-15 23:59:59',1,'2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL);
/*!40000 ALTER TABLE `member_coupon` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `member_coupon_log`
--

DROP TABLE IF EXISTS `member_coupon_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `member_coupon_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `coupon_id` bigint NOT NULL,
  `member_id` bigint NOT NULL,
  `status` varchar(16) NOT NULL DEFAULT 'UNUSED' COMMENT 'UNUSED/USED/EXPIRED',
  `order_no` varchar(64) DEFAULT NULL,
  `used_time` datetime DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  `version` int NOT NULL DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_coupon_log_member` (`member_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='卡券领取/核销记录';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `member_coupon_log`
--

LOCK TABLES `member_coupon_log` WRITE;
/*!40000 ALTER TABLE `member_coupon_log` DISABLE KEYS */;
INSERT INTO `member_coupon_log` VALUES (1,1,1,'USED','DD202610100001','2026-10-10 10:00:00','2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL);
/*!40000 ALTER TABLE `member_coupon_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `member_point_log`
--

DROP TABLE IF EXISTS `member_point_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `member_point_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `member_id` bigint NOT NULL,
  `change_type` varchar(16) NOT NULL COMMENT 'IN/OUT',
  `points` int NOT NULL,
  `before_points` int NOT NULL DEFAULT '0',
  `after_points` int NOT NULL DEFAULT '0',
  `source` varchar(32) NOT NULL COMMENT 'ORDER/SIGN/REFUND/ADMIN',
  `biz_no` varchar(64) DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  `version` int NOT NULL DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_point_member` (`member_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='积分流水';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `member_point_log`
--

LOCK TABLES `member_point_log` WRITE;
/*!40000 ALTER TABLE `member_point_log` DISABLE KEYS */;
INSERT INTO `member_point_log` VALUES (1,1,'EARN',398,882,1280,'订单消费返积分','DD202610100001','2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL),(2,3,'EARN',60,500,560,'每日签到','SIGN20261018','2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL);
/*!40000 ALTER TABLE `member_point_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product`
--

DROP TABLE IF EXISTS `product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `product_no` varchar(64) NOT NULL,
  `category_id` bigint NOT NULL,
  `product_name` varchar(128) NOT NULL,
  `product_name_en` varchar(128) DEFAULT NULL,
  `main_image` varchar(512) DEFAULT NULL,
  `images` text COMMENT 'JSON 数组（图片上传组件产出）',
  `detail_html` longtext COMMENT '富文本（多语言 tab）',
  `detail_html_en` longtext,
  `origin` varchar(128) NOT NULL DEFAULT '鄱阳湖' COMMENT '产地',
  `sell_mode` varchar(16) NOT NULL DEFAULT 'BOTH' COMMENT 'RETAIL/WHOLESALE/BOTH',
  `retail_price` decimal(12,2) NOT NULL DEFAULT '0.00',
  `wholesale_price` decimal(12,2) NOT NULL DEFAULT '0.00' COMMENT '渠道专属批发价（后台可配置）',
  `min_order_qty` int NOT NULL DEFAULT '1' COMMENT '批发起订量，后台可配置',
  `live_room_id` bigint DEFAULT NULL COMMENT '直播间关联',
  `seo_title` varchar(255) DEFAULT NULL,
  `seo_keywords` varchar(255) DEFAULT NULL,
  `seo_desc` varchar(512) DEFAULT NULL,
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '1上架0下架',
  `sort` int NOT NULL DEFAULT '0',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  `version` int NOT NULL DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_product_no` (`product_no`),
  KEY `idx_product_category` (`category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商品（湖蟹）';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product`
--

LOCK TABLES `product` WRITE;
/*!40000 ALTER TABLE `product` DISABLE KEYS */;
INSERT INTO `product` VALUES (1,'P2026001',2,'鄱阳湖大闸蟹·精品礼盒（3.0-3.4两 8只）','Poyang Lake Hairy Crab Premium Gift Box','','[]','<p>精选鄱阳湖核心湖区大闸蟹，公母各 4 只，3.0-3.4 两规格，全程冷链直发。</p>',NULL,'江西·鄱阳湖','RETAIL',398.00,328.00,10,NULL,NULL,NULL,NULL,1,1,'2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,'年货季主推'),(2,'P2026002',1,'鄱阳湖生态大闸蟹·家庭装（2.5两 10只）','Poyang Lake Eco Crab Family Pack','','[]','<p>生态养殖湖区直供，2.5 两左右，10 只家庭装，适合日常家宴。</p>',NULL,'江西·鄱阳湖','BOTH',258.00,198.00,20,NULL,NULL,NULL,NULL,1,2,'2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,'日常走量款'),(3,'P2026003',3,'鄱阳湖湖蟹·批发大宗（2.0两 起）','Poyang Lake Crab Bulk Wholesale','','[]','<p>面向渠道商批发，公母分筐，支持按筐议价与信用额度结算。</p>',NULL,'江西·鄱阳湖','WHOLESALE',168.00,128.00,100,NULL,NULL,NULL,NULL,1,3,'2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,'渠道批发专用');
/*!40000 ALTER TABLE `product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_category`
--

DROP TABLE IF EXISTS `product_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_category` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `parent_id` bigint NOT NULL DEFAULT '0',
  `category_name` varchar(64) NOT NULL,
  `category_name_en` varchar(64) DEFAULT NULL,
  `icon` varchar(512) DEFAULT NULL,
  `sort` int NOT NULL DEFAULT '0',
  `status` tinyint NOT NULL DEFAULT '1',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  `version` int NOT NULL DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_category_parent` (`parent_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商品分类';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_category`
--

LOCK TABLES `product_category` WRITE;
/*!40000 ALTER TABLE `product_category` DISABLE KEYS */;
INSERT INTO `product_category` VALUES (1,0,'鲜活湖蟹','Live Crab',NULL,1,1,'2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL),(2,0,'礼盒装','Gift Box',NULL,2,1,'2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL),(3,0,'批发大宗','Bulk Wholesale',NULL,3,1,'2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL);
/*!40000 ALTER TABLE `product_category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_sku`
--

DROP TABLE IF EXISTS `product_sku`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_sku` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `product_id` bigint NOT NULL,
  `spec_id` bigint DEFAULT NULL,
  `sku_no` varchar(64) NOT NULL,
  `sku_name` varchar(128) NOT NULL,
  `retail_price` decimal(12,2) NOT NULL DEFAULT '0.00',
  `wholesale_price` decimal(12,2) NOT NULL DEFAULT '0.00',
  `cost_price` decimal(12,2) NOT NULL DEFAULT '0.00',
  `image` varchar(512) DEFAULT NULL,
  `status` tinyint NOT NULL DEFAULT '1',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  `version` int NOT NULL DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_sku_no` (`sku_no`),
  KEY `idx_sku_product` (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商品 SKU';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_sku`
--

LOCK TABLES `product_sku` WRITE;
/*!40000 ALTER TABLE `product_sku` DISABLE KEYS */;
INSERT INTO `product_sku` VALUES (1,1,1,'SKU2026001','精品礼盒 3.0-3.4两 公母各4只',398.00,328.00,210.00,NULL,1,'2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL),(2,2,2,'SKU2026002','家庭装 2.5两 10只',258.00,198.00,140.00,NULL,1,'2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL),(3,3,3,'SKU2026003','批发 公蟹 2.0-2.4两 50只',168.00,128.00,90.00,NULL,1,'2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL),(4,3,4,'SKU2026004','批发 母蟹 2.0-2.4两 50只',178.00,138.00,95.00,NULL,1,'2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL);
/*!40000 ALTER TABLE `product_sku` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_spec`
--

DROP TABLE IF EXISTS `product_spec`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_spec` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `product_id` bigint NOT NULL,
  `crab_sex` varchar(8) NOT NULL DEFAULT 'MALE' COMMENT 'MALE/FEMALE/MIXED',
  `weight_level` varchar(32) NOT NULL COMMENT '重量档，如 3.0-3.4两',
  `weight_min` decimal(6,2) DEFAULT NULL COMMENT '两',
  `weight_max` decimal(6,2) DEFAULT NULL,
  `piece_count` int NOT NULL DEFAULT '1' COMMENT '只数（礼盒）',
  `pack_type` varchar(32) NOT NULL DEFAULT 'GIFT_BOX' COMMENT 'GIFT_BOX/LOOSE',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  `version` int NOT NULL DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_spec_product` (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='湖蟹规格';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_spec`
--

LOCK TABLES `product_spec` WRITE;
/*!40000 ALTER TABLE `product_spec` DISABLE KEYS */;
INSERT INTO `product_spec` VALUES (1,1,'MIXED','3.0-3.4两',3.00,3.40,8,'礼盒','2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL),(2,2,'MIXED','2.5-2.9两',2.50,2.90,10,'泡沫箱','2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL),(3,3,'MALE','2.0-2.4两',2.00,2.40,50,'批发筐','2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL),(4,3,'FEMALE','2.0-2.4两',2.00,2.40,50,'批发筐','2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL);
/*!40000 ALTER TABLE `product_spec` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stock`
--

DROP TABLE IF EXISTS `stock`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stock` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `sku_id` bigint NOT NULL,
  `warehouse` varchar(64) NOT NULL DEFAULT 'MAIN' COMMENT '仓库/冷链中转',
  `total_qty` int NOT NULL DEFAULT '0',
  `available_qty` int NOT NULL DEFAULT '0',
  `locked_qty` int NOT NULL DEFAULT '0' COMMENT '下单未支付锁定',
  `warn_qty` int NOT NULL DEFAULT '0' COMMENT '预警值',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  `version` int NOT NULL DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_stock_sku_wh` (`sku_id`,`warehouse`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='库存（共用于自营+批发）';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock`
--

LOCK TABLES `stock` WRITE;
/*!40000 ALTER TABLE `stock` DISABLE KEYS */;
INSERT INTO `stock` VALUES (1,1,'鄱阳湖主仓',300,280,20,30,'2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL),(2,2,'鄱阳湖主仓',200,180,20,30,'2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL),(3,3,'南昌中转仓',500,450,50,100,'2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL),(4,4,'南昌中转仓',500,470,30,100,'2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL);
/*!40000 ALTER TABLE `stock` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stock_log`
--

DROP TABLE IF EXISTS `stock_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stock_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `sku_id` bigint NOT NULL,
  `warehouse` varchar(64) NOT NULL DEFAULT 'MAIN',
  `change_type` varchar(16) NOT NULL COMMENT 'IN/OUT/LOCK/UNLOCK',
  `qty` int NOT NULL,
  `biz_type` varchar(32) DEFAULT NULL COMMENT 'ORDER/SHIP/REFUND/ADMIN',
  `biz_no` varchar(64) DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  `version` int NOT NULL DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_stock_log_sku` (`sku_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='库存流水';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock_log`
--

LOCK TABLES `stock_log` WRITE;
/*!40000 ALTER TABLE `stock_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `stock_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_audit_log`
--

DROP TABLE IF EXISTS `sys_audit_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_audit_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint DEFAULT NULL,
  `username` varchar(64) DEFAULT NULL,
  `module` varchar(64) DEFAULT NULL,
  `operation` varchar(64) DEFAULT NULL COMMENT 'CREATE/UPDATE/DELETE/QUERY/LOGIN/PUBLISH',
  `method` varchar(255) DEFAULT NULL,
  `request_uri` varchar(512) DEFAULT NULL,
  `request_param` text,
  `ip` varchar(64) DEFAULT NULL,
  `user_agent` varchar(512) DEFAULT NULL,
  `success` tinyint NOT NULL DEFAULT '1',
  `error_msg` varchar(1024) DEFAULT NULL,
  `cost_ms` bigint DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_audit_user` (`user_id`),
  KEY `idx_audit_create_time` (`create_time`)
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='全操作审计日志（只读）';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_audit_log`
--

LOCK TABLES `sys_audit_log` WRITE;
/*!40000 ALTER TABLE `sys_audit_log` DISABLE KEYS */;
INSERT INTO `sys_audit_log` VALUES (1,NULL,NULL,'认证中心','LOGIN','AuthController.login(..)','/api/auth/login',NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT; Windows NT 10.0; zh-CN) WindowsPowerShell/5.1.19041.6456',0,'账号或密码错误',650,'2026-10-18 17:36:10'),(2,NULL,NULL,'认证中心','LOGIN','AuthController.login(..)','/api/auth/login',NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT; Windows NT 10.0; zh-CN) WindowsPowerShell/5.1.19041.6456',1,NULL,222,'2026-10-18 17:37:31'),(3,1,'admin','对象存储','QUERY','SysStorageConfigController.test(..)','/api/system/storage/test','[\"LOCAL\",{}]','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT; Windows NT 10.0; zh-CN) WindowsPowerShell/5.1.19041.6456',1,NULL,23,'2026-10-18 17:37:49'),(4,1,'admin','对象存储','UPDATE','SysStorageConfigController.apply(..)','/api/system/storage/apply','[\"LOCAL\",{}]','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT; Windows NT 10.0; zh-CN) WindowsPowerShell/5.1.19041.6456',0,NULL,36,'2026-10-18 17:37:49'),(5,1,'admin','对象存储','UPDATE','SysStorageConfigController.apply(..)','/api/system/storage/apply','[\"LOCAL\",{}]','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT; Windows NT 10.0; zh-CN) WindowsPowerShell/5.1.19041.6456',1,NULL,1042,'2026-10-18 17:41:19'),(6,1,'admin','文件管理','CREATE','SysFileController.upload(..)','/api/system/file/upload','[Ljava.lang.Object;@74992734','0:0:0:0:0:0:0:1','curl/8.13.0',1,NULL,25,'2026-10-18 17:41:31'),(7,NULL,NULL,'认证中心','LOGIN','AuthController.login(..)','/api/auth/login',NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT; Windows NT 10.0; zh-CN) WindowsPowerShell/5.1.19041.6456',1,NULL,258,'2026-10-18 19:51:06'),(8,1,'admin','对象存储','QUERY','SysStorageConfigController.test(..)','/api/system/storage/test','[\"LOCAL\",{}]','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT; Windows NT 10.0; zh-CN) WindowsPowerShell/5.1.19041.6456',1,NULL,41,'2026-10-18 19:51:06'),(9,1,'admin','对象存储','UPDATE','SysStorageConfigController.apply(..)','/api/system/storage/apply','[\"LOCAL\",{}]','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT; Windows NT 10.0; zh-CN) WindowsPowerShell/5.1.19041.6456',1,NULL,74,'2026-10-18 19:51:06'),(10,NULL,NULL,'认证中心','LOGIN','AuthController.login(..)','/api/auth/login',NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT; Windows NT 10.0; zh-CN) WindowsPowerShell/5.1.19041.6456',1,NULL,148,'2026-10-18 19:51:57'),(11,1,'admin','对象存储','QUERY','SysStorageConfigController.test(..)','/api/system/storage/test','[\"LOCAL\",{}]','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT; Windows NT 10.0; zh-CN) WindowsPowerShell/5.1.19041.6456',1,NULL,33,'2026-10-18 19:51:57'),(12,1,'admin','对象存储','UPDATE','SysStorageConfigController.apply(..)','/api/system/storage/apply','[\"LOCAL\",{}]','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT; Windows NT 10.0; zh-CN) WindowsPowerShell/5.1.19041.6456',1,NULL,73,'2026-10-18 19:51:57'),(13,NULL,NULL,'认证中心','LOGIN','AuthController.login(..)','/api/auth/login',NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT; Windows NT 10.0; zh-CN) WindowsPowerShell/5.1.19041.6456',1,NULL,118,'2026-10-18 19:52:08'),(14,1,'admin','对象存储','QUERY','SysStorageConfigController.test(..)','/api/system/storage/test','[\"LOCAL\",{}]','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT; Windows NT 10.0; zh-CN) WindowsPowerShell/5.1.19041.6456',1,NULL,47,'2026-10-18 19:52:08'),(15,1,'admin','对象存储','UPDATE','SysStorageConfigController.apply(..)','/api/system/storage/apply','[\"LOCAL\",{}]','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT; Windows NT 10.0; zh-CN) WindowsPowerShell/5.1.19041.6456',1,NULL,65,'2026-10-18 19:52:08'),(16,NULL,NULL,'认证中心','LOGIN','AuthController.login(..)','/api/auth/login',NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT; Windows NT 10.0; zh-CN) WindowsPowerShell/5.1.19041.6456',1,NULL,123,'2026-10-18 19:54:20'),(17,1,'admin','文件管理','CREATE','SysFileController.upload(..)','/api/system/file/upload','[Ljava.lang.Object;@25cb91a8','0:0:0:0:0:0:0:1','curl/8.13.0',1,NULL,19,'2026-10-18 19:54:21'),(18,NULL,NULL,'认证中心','LOGIN','AuthController.login(..)','/api/auth/login',NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:158.0) Gecko/20100101 Firefox/158.0',1,NULL,378,'2026-10-18 20:13:30'),(19,NULL,NULL,'认证中心','LOGIN','AuthController.login(..)','/api/auth/login',NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:158.0) Gecko/20100101 Firefox/158.0',1,NULL,119,'2026-10-18 20:13:37'),(20,NULL,NULL,'认证中心','LOGIN','AuthController.login(..)','/api/auth/login',NULL,'127.0.0.1','curl/8.13.0',1,NULL,100,'2026-10-18 20:14:12'),(21,NULL,NULL,'认证中心','LOGIN','AuthController.login(..)','/api/auth/login',NULL,'0:0:0:0:0:0:0:1','curl/8.13.0',1,NULL,97,'2026-10-18 20:14:12'),(22,NULL,NULL,'认证中心','LOGIN','AuthController.login(..)','/api/auth/login',NULL,'0:0:0:0:0:0:0:1','curl/8.13.0',1,NULL,94,'2026-10-18 20:14:12'),(23,NULL,NULL,'认证中心','LOGIN','AuthController.login(..)','/api/auth/login',NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) OpenCode/2.0.30 Chrome/152.0.7977.130 Electron/44.4.5 Safari/537.36',1,NULL,102,'2026-10-18 20:15:07'),(24,NULL,NULL,'认证中心','LOGIN','AuthController.login(..)','/api/auth/login',NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) OpenCode/2.0.30 Chrome/152.0.7977.130 Electron/44.4.5 Safari/537.36',1,NULL,129,'2026-10-18 20:16:51'),(25,NULL,NULL,'认证中心','LOGIN','AuthController.login(..)','/api/auth/login',NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) OpenCode/2.0.30 Chrome/152.0.7977.130 Electron/44.4.5 Safari/537.36',1,NULL,121,'2026-10-18 20:21:03'),(26,1,'admin','对象存储','QUERY','SysStorageConfigController.test(..)','/api/system/storage/test','[\"LOCAL\",{\"basePath\":\"/data/upload\",\"domain\":\"https://xiegongzhu.com/files\"}]','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) OpenCode/2.0.30 Chrome/152.0.7977.130 Electron/44.4.5 Safari/537.36',1,NULL,22,'2026-10-18 20:24:02'),(27,1,'admin','对象存储','UPDATE','SysStorageConfigController.apply(..)','/api/system/storage/apply','[\"LOCAL\",{\"basePath\":\"/data/upload\",\"domain\":\"https://xiegongzhu.com/files\"}]','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) OpenCode/2.0.30 Chrome/152.0.7977.130 Electron/44.4.5 Safari/537.36',1,NULL,52,'2026-10-18 20:24:04'),(28,1,'admin','系统参数','UPDATE','SysConfigController.saveGrouped(..)','/api/system/config/save-grouped','[{\"site.name\":\"螃蟹小公主｜鄱阳湖湖蟹X\",\"site.domain\":\"xiegongzhu.com\",\"site.logo\":\"\",\"site.copyright\":\"© 螃蟹小公主\",\"site.icp\":\"\",\"service.hotline\":\"400-000-0000\",\"service.qrcode\":\"\",\"wechat.mp.appid\":\"\",\"wechat.mp.secret\":\"\",\"wechat.mini.appid\":\"\",\"wechat.mini.secret\":\"\",\"wechat.pay.mchid\":\"\",\"wechat.pay.apiv3key\":\"\",\"alipay.appid\":\"\",\"alipay.privatekey\":\"\",\"storage.active.driver\":\"MINIO\",\"business.order.expire.minutes\":\"30\",\"business.channel.min.order.qty\":\"10\",\"business.channel.default.commission.rate\":\"5.00\",\"business.channel.default.referral.rate\":\"2.00\",\"business.channel.default.credit.quota\":\"100000.00\",\"business.freight.cold.chain\":\"0.00\",\"business.agreement.enabled\":\"true\"}]','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) OpenCode/2.0.30 Chrome/152.0.7977.130 Electron/44.4.5 Safari/537.36',1,NULL,161,'2026-10-18 20:24:40'),(29,1,'admin','系统参数','UPDATE','SysConfigController.saveGrouped(..)','/api/system/config/save-grouped','[{\"site.name\":\"螃蟹小公主｜鄱阳湖湖蟹\",\"site.domain\":\"xiegongzhu.com\",\"site.logo\":\"\",\"site.copyright\":\"© 螃蟹小公主\",\"site.icp\":\"\",\"service.hotline\":\"400-000-0000\",\"service.qrcode\":\"\",\"wechat.mp.appid\":\"\",\"wechat.mp.secret\":\"\",\"wechat.mini.appid\":\"\",\"wechat.mini.secret\":\"\",\"wechat.pay.mchid\":\"\",\"wechat.pay.apiv3key\":\"\",\"alipay.appid\":\"\",\"alipay.privatekey\":\"\",\"storage.active.driver\":\"MINIO\",\"business.order.expire.minutes\":\"30\",\"business.channel.min.order.qty\":\"10\",\"business.channel.default.commission.rate\":\"5.00\",\"business.channel.default.referral.rate\":\"2.00\",\"business.channel.default.credit.quota\":\"100000.00\",\"business.freight.cold.chain\":\"0.00\",\"business.agreement.enabled\":\"true\"}]','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) OpenCode/2.0.30 Chrome/152.0.7977.130 Electron/44.4.5 Safari/537.36',1,NULL,122,'2026-10-18 20:24:42'),(30,NULL,NULL,'认证中心','LOGIN','AuthController.login(..)','/api/auth/login',NULL,'127.0.0.1','curl/8.13.0',1,NULL,614,'2026-10-18 20:32:46'),(31,NULL,NULL,'认证中心','LOGIN','AuthController.login(..)','/api/auth/login',NULL,'127.0.0.1','curl/8.13.0',1,NULL,169,'2026-10-18 20:33:43'),(32,NULL,NULL,'认证中心','LOGIN','AuthController.login(..)','/api/auth/login',NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:158.0) Gecko/20100101 Firefox/158.0',1,NULL,117,'2026-10-18 20:37:30'),(33,NULL,NULL,'认证中心','LOGIN','AuthController.login(..)','/api/auth/login',NULL,'127.0.0.1','curl/8.13.0',1,NULL,144,'2026-10-18 20:55:53'),(34,NULL,NULL,'认证中心','LOGIN','AuthController.login(..)','/api/auth/login',NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) OpenCode/2.0.30 Chrome/152.0.7977.130 Electron/44.4.5 Safari/537.36',1,NULL,253,'2026-10-18 20:59:21'),(35,NULL,NULL,'认证中心','LOGIN','AuthController.login(..)','/api/auth/login',NULL,'127.0.0.1','curl/8.13.0',1,NULL,155,'2026-10-18 21:04:58'),(36,1,'admin','文件管理','CREATE','SysFileController.upload(..)','/api/system/file/upload','[Ljava.lang.Object;@2a28daed','127.0.0.1','curl/8.13.0',1,NULL,49,'2026-10-18 21:04:59'),(37,NULL,NULL,'认证中心','LOGIN','AuthController.login(..)','/api/auth/login',NULL,'127.0.0.1','curl/8.13.0',1,NULL,104,'2026-10-18 21:05:30'),(38,1,'admin','渠道商管理','UPDATE','ChannelBizController.auditReport(..)','/api/channel/biz/report/audit','[\"RP202610180002\",true,\"后台审核通过\"]','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:158.0) Gecko/20100101 Firefox/158.0',1,NULL,210,'2026-10-18 21:19:25'),(39,NULL,NULL,'认证中心','LOGIN','AuthController.login(..)','/api/auth/login',NULL,'0:0:0:0:0:0:0:1','curl/8.13.0',1,NULL,776,'2026-10-18 21:44:09'),(40,NULL,NULL,'认证中心','LOGIN','AuthController.login(..)','/api/auth/login',NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) OpenCode/2.0.30 Chrome/152.0.7977.130 Electron/44.4.5 Safari/537.36',1,NULL,465,'2026-10-18 21:44:26'),(41,NULL,NULL,'认证中心','LOGIN','AuthController.login(..)','/api/auth/login',NULL,'0:0:0:0:0:0:0:1','curl/8.13.0',1,NULL,326,'2026-10-18 21:45:41'),(42,NULL,NULL,'认证中心','LOGIN','AuthController.login(..)','/api/auth/login',NULL,'0:0:0:0:0:0:0:1','curl/8.13.0',1,NULL,419,'2026-10-18 21:54:11');
/*!40000 ALTER TABLE `sys_audit_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_config`
--

DROP TABLE IF EXISTS `sys_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_config` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `config_key` varchar(128) NOT NULL,
  `config_name` varchar(128) NOT NULL,
  `config_group` varchar(32) NOT NULL DEFAULT 'SITE' COMMENT 'SITE/ICP/SERVICE/WECHAT/PAY/STORAGE/BUSINESS',
  `config_value` text,
  `value_type` varchar(16) NOT NULL DEFAULT 'STRING' COMMENT 'STRING/NUMBER/BOOL/JSON',
  `is_encrypted` tinyint NOT NULL DEFAULT '0' COMMENT '1 表示密文（AK/SK 等）',
  `editable` tinyint NOT NULL DEFAULT '1',
  `sort` int NOT NULL DEFAULT '0',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  `version` int NOT NULL DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_sys_config_key` (`config_key`)
) ENGINE=InnoDB AUTO_INCREMENT=93 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='系统全局参数';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_config`
--

LOCK TABLES `sys_config` WRITE;
/*!40000 ALTER TABLE `sys_config` DISABLE KEYS */;
INSERT INTO `sys_config` VALUES (1,'site.name','平台名称','SITE','螃蟹小公主｜鄱阳湖湖蟹','STRING',0,1,0,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,2,NULL),(2,'site.domain','平台域名','SITE','xiegongzhu.com','STRING',0,1,0,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,2,NULL),(3,'site.logo','站点 Logo','SITE','','STRING',0,1,0,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,2,NULL),(4,'site.icp','ICP 备案号','ICP','','STRING',0,1,0,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,2,NULL),(5,'site.copyright','版权信息','SITE','© 螃蟹小公主','STRING',0,1,0,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,2,NULL),(6,'service.hotline','客服热线','SERVICE','400-000-0000','STRING',0,1,0,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,2,NULL),(7,'service.qrcode','客服二维码','SERVICE','','STRING',0,1,0,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,2,NULL),(8,'wechat.mp.appid','服务号 AppID','WECHAT','','STRING',0,1,0,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,2,NULL),(9,'wechat.mp.secret','服务号 Secret','WECHAT','','STRING',1,1,0,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,2,NULL),(10,'wechat.mini.appid','小程序 AppID','WECHAT','','STRING',0,1,0,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,2,NULL),(11,'wechat.mini.secret','小程序 Secret','WECHAT','','STRING',1,1,0,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,2,NULL),(12,'wechat.pay.mchid','微信支付商户号','PAY','','STRING',0,1,0,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,2,NULL),(13,'wechat.pay.apiv3key','微信支付 APIv3 密钥','PAY','','STRING',1,1,0,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,2,NULL),(14,'alipay.appid','支付宝 AppID','PAY','','STRING',0,1,0,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,2,NULL),(15,'alipay.privatekey','支付宝私钥','PAY','','STRING',1,1,0,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,2,NULL),(16,'storage.active.driver','当前对象存储驱动','STORAGE','MINIO','STRING',0,1,0,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,2,NULL),(17,'business.order.expire.minutes','订单未支付超时(分钟)','BUSINESS','30','NUMBER',0,1,0,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,2,NULL),(18,'business.channel.min.order.qty','批发起订量','BUSINESS','10','NUMBER',0,1,0,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,2,NULL),(19,'business.channel.default.commission.rate','渠道默认分销佣金比例(%)','BUSINESS','5.00','NUMBER',0,1,0,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,2,NULL),(20,'business.channel.default.referral.rate','转介绍返佣比例(%)','BUSINESS','2.00','NUMBER',0,1,0,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,2,NULL),(21,'business.channel.default.credit.quota','渠道默认授信额度','BUSINESS','100000.00','NUMBER',0,1,0,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,2,NULL),(22,'business.freight.cold.chain','冷链运费(元)','BUSINESS','0.00','NUMBER',0,1,0,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,2,NULL),(23,'business.agreement.enabled','下单协议弹窗开关','BUSINESS','true','BOOL',0,1,0,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,2,NULL);
/*!40000 ALTER TABLE `sys_config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_dict`
--

DROP TABLE IF EXISTS `sys_dict`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_dict` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `dict_type` varchar(64) NOT NULL,
  `dict_name` varchar(64) NOT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  `version` int NOT NULL DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_sys_dict_type` (`dict_type`)
) ENGINE=InnoDB AUTO_INCREMENT=78 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='字典类型';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_dict`
--

LOCK TABLES `sys_dict` WRITE;
/*!40000 ALTER TABLE `sys_dict` DISABLE KEYS */;
INSERT INTO `sys_dict` VALUES (1,'order_status','订单状态','2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL),(2,'pay_type','支付方式','2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL),(3,'crab_sex','湖蟹公母','2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL),(4,'ship_status','冷链发货状态','2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL),(5,'pay_status','支付状态','2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(6,'biz_mode','业务模式','2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(7,'sell_mode','销售模式','2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(8,'order_source','订单来源','2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(9,'channel_level','渠道等级','2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(10,'channel_status','渠道状态','2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(11,'member_level','会员等级','2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(12,'gender','性别','2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(13,'audit_status','审核状态','2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(14,'settle_status','佣金结算状态','2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(15,'settlement_status','结算单状态','2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(16,'commission_type','佣金类型','2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(17,'change_type','变动类型','2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(18,'coupon_type','卡券类型','2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(19,'article_status','文章状态','2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(20,'status','通用状态','2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(21,'yes_no','是否','2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(22,'platform','平台','2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(23,'menu_type','菜单类型','2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(24,'link_type','链接类型','2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(53,'payment_status','支付流水状态','2026-10-18 22:03:13','2026-10-18 22:03:13',0,0,NULL);
/*!40000 ALTER TABLE `sys_dict` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_dict_item`
--

DROP TABLE IF EXISTS `sys_dict_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_dict_item` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `dict_type` varchar(64) NOT NULL,
  `item_label` varchar(64) NOT NULL,
  `item_value` varchar(64) NOT NULL,
  `sort` int NOT NULL DEFAULT '0',
  `status` tinyint NOT NULL DEFAULT '1',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  `version` int NOT NULL DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_dict_item_type` (`dict_type`)
) ENGINE=InnoDB AUTO_INCREMENT=99 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='字典项';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_dict_item`
--

LOCK TABLES `sys_dict_item` WRITE;
/*!40000 ALTER TABLE `sys_dict_item` DISABLE KEYS */;
INSERT INTO `sys_dict_item` VALUES (1,'order_status','待支付','UNPAID',1,1,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL),(2,'order_status','已支付','PAID',2,1,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL),(3,'order_status','分拣中','SORTING',3,1,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL),(4,'order_status','已打包','PACKED',4,1,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL),(5,'order_status','已发货','SHIPPED',5,1,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL),(6,'order_status','已收货','RECEIVED',6,1,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL),(7,'order_status','已完成','COMPLETED',7,1,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL),(8,'order_status','已取消','CANCELLED',8,1,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL),(9,'pay_type','微信支付','WECHAT',1,1,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL),(10,'pay_type','支付宝','ALIPAY',2,1,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL),(11,'pay_type','储值余额','BALANCE',3,1,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL),(12,'crab_sex','公蟹','MALE',1,1,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL),(13,'crab_sex','母蟹','FEMALE',2,1,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL),(14,'crab_sex','公母混装','MIXED',3,1,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL),(15,'ship_status','待发货','WAIT',1,1,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL),(16,'ship_status','分拣中','SORTING',2,1,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL),(17,'ship_status','已打包','PACKED',3,1,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL),(18,'ship_status','已出库','OUTBOUND',4,1,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL),(19,'ship_status','已发货','SHIPPED',5,1,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL),(20,'ship_status','运输中','IN_TRANSIT',6,1,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL),(21,'ship_status','已签收','SIGNED',7,1,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL),(22,'order_status','退款中','REFUNDING',9,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(23,'order_status','已退款','REFUNDED',10,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(24,'pay_type','对公转账','CASH',4,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(25,'pay_status','未支付','UNPAID',1,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(26,'pay_status','已支付','PAID',2,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(27,'pay_status','退款中','REFUNDING',3,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(28,'pay_status','已退款','REFUNDED',4,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(29,'pay_status','部分退款','PARTIAL_REFUNDED',5,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(30,'biz_mode','自营零售','RETAIL',1,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(31,'biz_mode','渠道批发','WHOLESALE',2,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(32,'sell_mode','仅自营','RETAIL',1,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(33,'sell_mode','仅批发','WHOLESALE',2,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(34,'sell_mode','自营+批发','BOTH',3,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(35,'order_source','小程序','MINIAPP',1,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(36,'order_source','H5 商城','H5',2,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(37,'order_source','PC 官网','PC',3,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(38,'order_source','后台代客下单','ADMIN',4,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(39,'order_source','渠道商端','CHANNEL',5,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(40,'channel_level','一级渠道','L1',1,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(41,'channel_level','二级渠道','L2',2,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(42,'channel_level','三级渠道','L3',3,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(43,'channel_status','待审核','PENDING',1,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(44,'channel_status','正常','NORMAL',2,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(45,'channel_status','已驳回','REJECTED',3,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(46,'channel_status','已冻结','FROZEN',4,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(47,'member_level','普通会员','NORMAL',1,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(48,'member_level','银卡会员','SILVER',2,1,'2026-10-18 21:29:45','2026-10-18 21:39:24',0,0,NULL),(49,'member_level','金卡会员','GOLD',3,1,'2026-10-18 21:29:45','2026-10-18 21:39:24',0,0,NULL),(50,'member_level','黑卡会员','BLACK',4,1,'2026-10-18 21:29:45','2026-10-18 21:39:24',0,0,NULL),(51,'gender','未知','0',1,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(52,'gender','男','1',2,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(53,'gender','女','2',3,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(54,'audit_status','待审核','PENDING',1,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(55,'audit_status','已通过','APPROVED',2,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(56,'audit_status','已驳回','REJECTED',3,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(57,'settle_status','待结算','PENDING',1,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(58,'settle_status','已结算','SETTLED',2,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(59,'settle_status','已作废','CANCELLED',3,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(60,'settlement_status','草稿','DRAFT',1,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(61,'settlement_status','已确认','CONFIRMED',2,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(62,'settlement_status','已打款','PAID',3,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(63,'commission_type','分销佣金','SALE',1,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(64,'commission_type','转介绍返佣','REFERRAL',2,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(65,'commission_type','团队级差','TEAM',3,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(66,'change_type','增加','EARN',1,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(67,'change_type','消费','CONSUME',2,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(68,'change_type','退回','REFUND',3,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(69,'change_type','后台调整','ADMIN',4,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(70,'change_type','提额','INCREASE',5,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(71,'change_type','占用','OCCUPY',6,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(72,'change_type','释放','RELEASE',7,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(73,'coupon_type','满减券','CASH',1,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(74,'coupon_type','折扣券','DISCOUNT',2,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(75,'article_status','草稿','DRAFT',1,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(76,'article_status','已发布','PUBLISHED',2,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(77,'article_status','已下线','OFFLINE',3,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(78,'status','启用','1',1,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(79,'status','停用','0',2,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(80,'yes_no','是','1',1,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(81,'yes_no','否','0',2,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(82,'platform','后台菜单','ADMIN',1,1,'2026-10-18 21:29:45','2026-10-18 21:39:24',0,0,NULL),(83,'platform','PC 官网导航','PC',2,1,'2026-10-18 21:29:45','2026-10-18 21:39:24',0,0,NULL),(84,'platform','公众号菜单','WECHAT_MP',3,1,'2026-10-18 21:29:45','2026-10-18 21:39:24',0,0,NULL),(85,'platform','小程序 tabBar','MINIAPP',4,1,'2026-10-18 21:29:45','2026-10-18 21:39:24',0,0,NULL),(86,'menu_type','目录','DIR',1,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(87,'menu_type','菜单','MENU',2,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(88,'menu_type','按钮','BUTTON',3,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(89,'link_type','站内路由','INNER',1,1,'2026-10-18 21:29:45','2026-10-18 21:39:24',0,0,NULL),(90,'link_type','外部链接','OUTER',2,1,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(91,'coupon_type','赠品券','GIFT',3,1,'2026-10-18 21:39:24','2026-10-18 21:39:24',0,0,NULL),(92,'platform','H5 底部导航','H5',5,1,'2026-10-18 21:39:24','2026-10-18 21:39:24',0,0,NULL),(93,'platform','渠道商端','CHANNEL',6,1,'2026-10-18 21:39:24','2026-10-18 21:39:24',0,0,NULL),(94,'link_type','小程序页面','MINIAPP',3,1,'2026-10-18 21:39:24','2026-10-18 21:39:24',0,0,NULL),(95,'payment_status','未支付','UNPAID',1,1,'2026-10-18 21:50:19','2026-10-18 22:03:14',1,0,''),(96,'payment_status','支付成功','SUCCESS',2,1,'2026-10-18 22:03:14','2026-10-18 22:03:14',0,0,NULL),(97,'payment_status','支付失败','FAIL',3,1,'2026-10-18 22:03:14','2026-10-18 22:03:14',0,0,NULL),(98,'payment_status','已退款','REFUND',4,1,'2026-10-18 22:03:14','2026-10-18 22:03:14',0,0,NULL);
/*!40000 ALTER TABLE `sys_dict_item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_file`
--

DROP TABLE IF EXISTS `sys_file`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_file` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `driver` varchar(16) NOT NULL,
  `bucket` varchar(128) DEFAULT NULL,
  `object_key` varchar(512) NOT NULL,
  `url` varchar(1024) NOT NULL,
  `origin_name` varchar(255) DEFAULT NULL,
  `file_size` bigint DEFAULT NULL,
  `content_type` varchar(128) DEFAULT NULL,
  `biz_type` varchar(64) DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  `version` int NOT NULL DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_sys_file_biz` (`biz_type`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='文件记录';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_file`
--

LOCK TABLES `sys_file` WRITE;
/*!40000 ALTER TABLE `sys_file` DISABLE KEYS */;
INSERT INTO `sys_file` VALUES (3,'LOCAL',NULL,'product/2026/10/18/2111805740028153858.png','http://localhost:8080/api/files/product/2026/10/18/2111805740028153858.png','dot.png',70,'image/png','product','2026-10-18 21:04:59','2026-10-18 21:04:59',0,0,NULL);
/*!40000 ALTER TABLE `sys_file` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_i18n`
--

DROP TABLE IF EXISTS `sys_i18n`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_i18n` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `item_key` varchar(128) NOT NULL COMMENT '词条键，如 home.title',
  `lang_code` varchar(16) NOT NULL,
  `item_value` text,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  `version` int NOT NULL DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_i18n_key_lang` (`item_key`,`lang_code`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='多语言词条';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_i18n`
--

LOCK TABLES `sys_i18n` WRITE;
/*!40000 ALTER TABLE `sys_i18n` DISABLE KEYS */;
INSERT INTO `sys_i18n` VALUES (1,'site.title','zh-CN','螃蟹小公主 · 鄱阳湖湖蟹','2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL),(2,'site.title','en-US','Princess Crab · Poyang Lake Hairy Crab','2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL),(3,'nav.home','zh-CN','首页','2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL),(4,'nav.home','en-US','Home','2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL),(5,'nav.recruit','zh-CN','招商合作','2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL),(6,'nav.recruit','en-US','Partnership','2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL);
/*!40000 ALTER TABLE `sys_i18n` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_lang`
--

DROP TABLE IF EXISTS `sys_lang`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_lang` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `lang_code` varchar(16) NOT NULL COMMENT 'zh-CN / en-US',
  `lang_name` varchar(64) NOT NULL,
  `is_default` tinyint NOT NULL DEFAULT '0',
  `status` tinyint NOT NULL DEFAULT '1',
  `sort` int NOT NULL DEFAULT '0',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  `version` int NOT NULL DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_sys_lang_code` (`lang_code`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='语言列表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_lang`
--

LOCK TABLES `sys_lang` WRITE;
/*!40000 ALTER TABLE `sys_lang` DISABLE KEYS */;
INSERT INTO `sys_lang` VALUES (1,'zh-CN','简体中文',1,1,1,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL),(2,'en-US','English',0,1,2,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL);
/*!40000 ALTER TABLE `sys_lang` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_menu`
--

DROP TABLE IF EXISTS `sys_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_menu` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `parent_id` bigint NOT NULL DEFAULT '0',
  `menu_name` varchar(64) NOT NULL,
  `platform` varchar(16) NOT NULL DEFAULT 'ADMIN' COMMENT 'ADMIN/PC/WECHAT_MP/MINIAPP/H5',
  `menu_type` varchar(16) NOT NULL DEFAULT 'MENU' COMMENT 'DIR/MENU/BUTTON',
  `link_type` varchar(16) NOT NULL DEFAULT 'INNER' COMMENT 'INNER/OUTER/MINIAPP',
  `path` varchar(255) DEFAULT NULL,
  `component` varchar(255) DEFAULT NULL,
  `icon` varchar(64) DEFAULT NULL,
  `perm` varchar(128) DEFAULT NULL COMMENT '权限标识，如 product:edit',
  `sort` int NOT NULL DEFAULT '0',
  `visible` tinyint NOT NULL DEFAULT '1',
  `keep_alive` tinyint NOT NULL DEFAULT '1',
  `wx_publish_status` tinyint NOT NULL DEFAULT '0' COMMENT '公众号菜单：0未发布1已发布',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  `version` int NOT NULL DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_sys_menu_parent` (`parent_id`),
  KEY `idx_sys_menu_platform` (`platform`)
) ENGINE=InnoDB AUTO_INCREMENT=64 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='菜单/导航（多端）';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_menu`
--

LOCK TABLES `sys_menu` WRITE;
/*!40000 ALTER TABLE `sys_menu` DISABLE KEYS */;
INSERT INTO `sys_menu` VALUES (1,0,'系统管理','ADMIN','DIR','INNER','/system','Layout','Setting','system',100,1,1,0,'2026-10-18 17:29:29','2026-10-18 20:39:37',0,0,NULL),(2,1,'系统参数','ADMIN','MENU','INNER','/system/config','system/config/index','Tools','system:config:list',1,1,1,0,'2026-10-18 17:29:29','2026-10-18 20:39:27',0,0,NULL),(3,1,'多语言','ADMIN','MENU','INNER','/system/i18n','system/i18n/index','Translate','system:i18n:list',2,1,1,0,'2026-10-18 17:29:29','2026-10-18 20:39:27',0,0,NULL),(4,1,'菜单维护','ADMIN','MENU','INNER','/system/menu','system/menu/index','Menu','system:menu:list',4,1,1,0,'2026-10-18 17:29:29','2026-10-18 21:29:45',0,0,NULL),(5,1,'对象存储','ADMIN','MENU','INNER','/system/storage','system/storage/index','Cloudy','system:storage:list',5,1,1,0,'2026-10-18 17:29:29','2026-10-18 21:29:45',0,0,NULL),(6,1,'审计日志','ADMIN','MENU','INNER','/system/audit','system/audit/index','Notebook','system:audit:list',6,1,1,0,'2026-10-18 17:29:29','2026-10-18 21:29:45',0,0,NULL),(7,1,'字典管理','ADMIN','MENU','INNER','/system/dict','system/dict/index','Collection','system:dict:list',3,1,1,0,'2026-10-18 21:29:45','2026-10-18 21:29:45',0,0,NULL),(10,0,'商品中心','ADMIN','DIR','INNER','/product','Layout','Goods','product',200,1,1,0,'2026-10-18 17:29:29','2026-10-18 20:39:27',0,0,NULL),(11,10,'商品管理','ADMIN','MENU','INNER','/product/list','product/list/index','ShoppingBag','product:list',1,1,1,0,'2026-10-18 17:29:29','2026-10-18 20:39:37',0,0,NULL),(12,10,'分类管理','ADMIN','MENU','INNER','/product/category','product/category/index','Grid','product:category:list',2,1,1,0,'2026-10-18 17:29:29','2026-10-18 20:39:27',0,0,NULL),(13,10,'库存管理','ADMIN','MENU','INNER','/product/stock','product/stock/index','Box','product:stock:list',3,1,1,0,'2026-10-18 17:29:29','2026-10-18 20:39:27',0,0,NULL),(20,0,'交易中心','ADMIN','DIR','INNER','/trade','Layout','ShoppingCart','trade',300,1,1,0,'2026-10-18 17:29:29','2026-10-18 20:39:27',0,0,NULL),(21,20,'订单管理','ADMIN','MENU','INNER','/trade/order','trade/order/index','List','trade:order:list',1,1,1,0,'2026-10-18 17:29:29','2026-10-18 20:39:27',0,0,NULL),(22,20,'支付流水','ADMIN','MENU','INNER','/trade/payment','trade/payment/index','Money','trade:payment:list',2,1,1,0,'2026-10-18 17:29:29','2026-10-18 20:39:27',0,0,NULL),(23,20,'评价管理','ADMIN','MENU','INNER','/trade/review','trade/review/index','Star','trade:review:list',3,1,1,0,'2026-10-18 17:29:29','2026-10-18 20:39:27',0,0,NULL),(30,0,'冷链发货端','ADMIN','DIR','INNER','/ship','Layout','Van','ship',400,1,1,0,'2026-10-18 17:29:29','2026-10-18 20:39:27',0,0,NULL),(31,30,'待发货分拣','ADMIN','MENU','INNER','/ship/wait','ship/wait/index','Sort','ship:wait:list',1,1,1,0,'2026-10-18 17:29:29','2026-10-18 20:39:27',0,0,NULL),(32,30,'打包核验','ADMIN','MENU','INNER','/ship/pack','ship/pack/index','Checked','ship:pack:list',2,1,1,0,'2026-10-18 17:29:29','2026-10-18 20:39:27',0,0,NULL),(33,30,'出库发货','ADMIN','MENU','INNER','/ship/outbound','ship/outbound/index','Upload','ship:outbound:list',3,1,1,0,'2026-10-18 17:29:29','2026-10-18 20:39:27',0,0,NULL),(40,0,'渠道商管理','ADMIN','DIR','INNER','/channel','Layout','User','channel',500,1,1,0,'2026-10-18 17:29:29','2026-10-18 20:39:27',0,0,NULL),(41,40,'渠道档案','ADMIN','MENU','INNER','/channel/list','channel/list/index','UserFilled','channel:list',1,1,1,0,'2026-10-18 17:29:29','2026-10-18 20:39:27',0,0,NULL),(42,40,'报单审核','ADMIN','MENU','INNER','/channel/report','channel/report/index','EditPen','channel:report:list',2,1,1,0,'2026-10-18 17:29:29','2026-10-18 20:39:27',0,0,NULL),(43,40,'佣金规则','ADMIN','MENU','INNER','/channel/commission','channel/commission/index','Coin','channel:commission:list',3,1,1,0,'2026-10-18 17:29:29','2026-10-18 20:39:27',0,0,NULL),(44,40,'对账结算','ADMIN','MENU','INNER','/channel/settlement','channel/settlement/index','Files','channel:settlement:list',4,1,1,0,'2026-10-18 17:29:29','2026-10-18 20:39:37',0,0,NULL),(50,0,'会员中心','ADMIN','DIR','INNER','/member','Layout','Avatar','member',600,1,1,0,'2026-10-18 17:29:29','2026-10-18 20:39:37',0,0,NULL),(51,50,'会员列表','ADMIN','MENU','INNER','/member/list','member/list/index','User','member:list',1,1,1,0,'2026-10-18 17:29:29','2026-10-18 20:39:27',0,0,NULL),(52,50,'卡券管理','ADMIN','MENU','INNER','/member/coupon','member/coupon/index','Ticket','member:coupon:list',2,1,1,0,'2026-10-18 17:29:29','2026-10-18 20:39:27',0,0,NULL),(53,50,'积分储值','ADMIN','MENU','INNER','/member/assets','member/assets/index','Wallet','member:assets:list',3,1,1,0,'2026-10-18 17:29:29','2026-10-18 20:39:27',0,0,NULL),(60,0,'内容管理','ADMIN','DIR','INNER','/cms','Layout','Document','cms',700,1,1,0,'2026-10-18 17:29:29','2026-10-18 20:39:27',0,0,NULL),(61,60,'文章管理','ADMIN','MENU','INNER','/cms/article','cms/article/index','Document','cms:article:list',1,1,1,0,'2026-10-18 17:29:29','2026-10-18 20:39:27',0,0,NULL),(62,60,'栏目管理','ADMIN','MENU','INNER','/cms/category','cms/category/index','Folder','cms:category:list',2,1,1,0,'2026-10-18 17:29:29','2026-10-18 20:39:27',0,0,NULL),(63,60,'渠道申请','ADMIN','MENU','INNER','/cms/apply','cms/apply/index','Promotion','cms:apply:list',3,1,1,0,'2026-10-18 17:29:29','2026-10-18 20:39:37',0,0,NULL);
/*!40000 ALTER TABLE `sys_menu` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_role`
--

DROP TABLE IF EXISTS `sys_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_role` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `role_code` varchar(64) NOT NULL COMMENT 'MEMBER/SUPER_ADMIN/SHOP_MANAGER/FINANCE/SHIPPER/CHANNEL/CHANNEL_ADMIN',
  `role_name` varchar(64) NOT NULL,
  `data_scope` varchar(16) NOT NULL DEFAULT 'ALL' COMMENT 'ALL/SELF/CHANNEL',
  `sort` int NOT NULL DEFAULT '0',
  `status` tinyint NOT NULL DEFAULT '1',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  `version` int NOT NULL DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_sys_role_code` (`role_code`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='RBAC 角色';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_role`
--

LOCK TABLES `sys_role` WRITE;
/*!40000 ALTER TABLE `sys_role` DISABLE KEYS */;
INSERT INTO `sys_role` VALUES (1,'SUPER_ADMIN','超级管理员','ALL',1,1,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL),(2,'SHOP_MANAGER','店长','ALL',2,1,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL),(3,'FINANCE','财务','ALL',3,1,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL),(4,'SHIPPER','仓管/发货员','SELF',4,1,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL),(5,'CHANNEL','渠道商','CHANNEL',5,1,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL),(6,'CHANNEL_ADMIN','渠道商管理员','CHANNEL',6,1,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL),(7,'MEMBER','普通会员','SELF',7,1,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL);
/*!40000 ALTER TABLE `sys_role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_role_menu`
--

DROP TABLE IF EXISTS `sys_role_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_role_menu` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `role_id` bigint NOT NULL,
  `menu_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_role_menu` (`role_id`,`menu_id`)
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='角色-菜单';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_role_menu`
--

LOCK TABLES `sys_role_menu` WRITE;
/*!40000 ALTER TABLE `sys_role_menu` DISABLE KEYS */;
INSERT INTO `sys_role_menu` VALUES (1,1,1),(8,1,2),(9,1,3),(10,1,4),(11,1,5),(12,1,6),(32,1,7),(2,1,10),(13,1,11),(14,1,12),(15,1,13),(3,1,20),(16,1,21),(17,1,22),(18,1,23),(4,1,30),(19,1,31),(20,1,32),(21,1,33),(5,1,40),(22,1,41),(23,1,42),(24,1,43),(25,1,44),(6,1,50),(26,1,51),(27,1,52),(28,1,53),(7,1,60),(29,1,61),(30,1,62),(31,1,63);
/*!40000 ALTER TABLE `sys_role_menu` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_sensitive_word`
--

DROP TABLE IF EXISTS `sys_sensitive_word`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_sensitive_word` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `word` varchar(64) NOT NULL,
  `level` tinyint NOT NULL DEFAULT '1' COMMENT '1替换2拦截',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  `version` int NOT NULL DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_sensitive_word` (`word`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='敏感词';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_sensitive_word`
--

LOCK TABLES `sys_sensitive_word` WRITE;
/*!40000 ALTER TABLE `sys_sensitive_word` DISABLE KEYS */;
INSERT INTO `sys_sensitive_word` VALUES (1,'测试敏感词',1,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL),(2,'违规',2,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,0,NULL);
/*!40000 ALTER TABLE `sys_sensitive_word` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_storage_config`
--

DROP TABLE IF EXISTS `sys_storage_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_storage_config` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `driver` varchar(16) NOT NULL COMMENT 'LOCAL/S3/OSS/COS/MINIO',
  `config_json` text COMMENT '驱动参数（AK/SK 密文）',
  `is_active` tinyint NOT NULL DEFAULT '0',
  `test_passed` tinyint NOT NULL DEFAULT '0' COMMENT '连接测试通过才允许启用',
  `test_time` datetime DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  `version` int NOT NULL DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_storage_driver` (`driver`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='对象存储配置';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_storage_config`
--

LOCK TABLES `sys_storage_config` WRITE;
/*!40000 ALTER TABLE `sys_storage_config` DISABLE KEYS */;
INSERT INTO `sys_storage_config` VALUES (1,'LOCAL','{\"basePath\":\"/data/upload\",\"domain\":\"https://xiegongzhu.com/files\"}',1,1,'2026-10-18 20:24:02','2026-10-18 17:29:29','2026-10-18 17:29:29',0,10,NULL),(2,'S3','{\"endpoint\":\"\",\"region\":\"\",\"bucket\":\"\",\"accessKey\":\"\",\"secretKey\":\"\",\"domain\":\"\"}',0,0,NULL,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,5,NULL),(3,'OSS','{\"endpoint\":\"\",\"bucket\":\"\",\"accessKeyId\":\"\",\"accessKeySecret\":\"\",\"domain\":\"\"}',0,0,NULL,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,5,NULL),(4,'COS','{\"region\":\"\",\"bucket\":\"\",\"secretId\":\"\",\"secretKey\":\"\",\"domain\":\"\"}',0,0,NULL,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,5,NULL),(5,'MINIO','{\"endpoint\":\"http://minio:9000\",\"bucket\":\"xiegongzhu\",\"accessKey\":\"minioadmin\",\"secretKey\":\"minioadmin\",\"domain\":\"\"}',0,1,NULL,'2026-10-18 17:29:29','2026-10-18 17:29:29',0,5,NULL);
/*!40000 ALTER TABLE `sys_storage_config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_user`
--

DROP TABLE IF EXISTS `sys_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_user` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `username` varchar(64) NOT NULL COMMENT '登录名',
  `password` varchar(128) NOT NULL COMMENT 'BCrypt 密文',
  `real_name` varchar(64) DEFAULT NULL,
  `mobile` varchar(20) DEFAULT NULL,
  `avatar` varchar(512) DEFAULT NULL,
  `role_type` varchar(32) NOT NULL DEFAULT 'ADMIN' COMMENT '超级管理员/店长/财务/仓管发货员/渠道商管理员',
  `channel_id` bigint DEFAULT NULL COMMENT '渠道商用户归属渠道',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '1启用0禁用',
  `last_login_at` datetime DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  `version` int NOT NULL DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_sys_user_username` (`username`),
  KEY `idx_sys_user_channel` (`channel_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='后台用户';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_user`
--

LOCK TABLES `sys_user` WRITE;
/*!40000 ALTER TABLE `sys_user` DISABLE KEYS */;
INSERT INTO `sys_user` VALUES (1,'admin','$2a$10$MEKdwjLQmNOnsp5HNsYwBuhNMDvIOSzZuVPPgryWy4pT0ro0tiSZS','超级管理员',NULL,NULL,'SUPER_ADMIN',NULL,1,'2026-10-18 21:54:11','2026-10-18 17:29:29','2026-10-18 21:54:11',0,0,NULL);
/*!40000 ALTER TABLE `sys_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_user_role`
--

DROP TABLE IF EXISTS `sys_user_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_user_role` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `role_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_role` (`user_id`,`role_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户-角色';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_user_role`
--

LOCK TABLES `sys_user_role` WRITE;
/*!40000 ALTER TABLE `sys_user_role` DISABLE KEYS */;
INSERT INTO `sys_user_role` VALUES (1,1,1);
/*!40000 ALTER TABLE `sys_user_role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `t_channel`
--

DROP TABLE IF EXISTS `t_channel`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_channel` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `channel_no` varchar(64) NOT NULL,
  `channel_name` varchar(128) NOT NULL,
  `contact_name` varchar(64) NOT NULL,
  `contact_mobile` varchar(20) NOT NULL,
  `union_id` varchar(64) DEFAULT NULL COMMENT 'UnionID 体系登录',
  `channel_level` varchar(16) NOT NULL DEFAULT 'L1' COMMENT 'L1/L2/L3',
  `parent_id` bigint NOT NULL DEFAULT '0' COMMENT '上级渠道（0 顶级）',
  `commission_rate` decimal(5,2) NOT NULL DEFAULT '0.00' COMMENT '分销佣金比例 %（后台可配置）',
  `referral_rate` decimal(5,2) NOT NULL DEFAULT '0.00' COMMENT '转介绍返佣比例 %（后台可配置）',
  `credit_quota` decimal(14,2) NOT NULL DEFAULT '0.00' COMMENT '授信额度',
  `used_quota` decimal(14,2) NOT NULL DEFAULT '0.00',
  `time_price` decimal(12,2) NOT NULL DEFAULT '0.00' COMMENT '年返/吞吐返点（丙方口径）',
  `status` varchar(16) NOT NULL DEFAULT 'PENDING' COMMENT 'PENDING待审核/NORMAL/REJECTED/FROZEN',
  `license_images` text COMMENT '资质图片 JSON',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  `version` int NOT NULL DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_channel_no` (`channel_no`),
  UNIQUE KEY `uk_channel_union` (`union_id`),
  KEY `idx_channel_parent` (`parent_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='渠道商（经销商/代理）';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_channel`
--

LOCK TABLES `t_channel` WRITE;
/*!40000 ALTER TABLE `t_channel` DISABLE KEYS */;
INSERT INTO `t_channel` VALUES (1,'CH2026001','南昌蟹逅商贸有限公司','王经理','13900000001','oU_channel_001','L1',0,8.00,3.00,50000.00,12000.00,0.00,'NORMAL',NULL,'2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,'区域一级经销商'),(2,'CH2026002','九江鲜生优选','李总','13900000002','oU_channel_002','L2',1,5.00,2.00,20000.00,3000.00,0.00,'NORMAL',NULL,'2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,'九江二级经销商');
/*!40000 ALTER TABLE `t_channel` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `t_channel_order`
--

DROP TABLE IF EXISTS `t_channel_order`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_channel_order` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `report_no` varchar(64) NOT NULL COMMENT '报单号',
  `channel_id` bigint NOT NULL,
  `order_no` varchar(64) DEFAULT NULL COMMENT '审核通过后生成的自营订单号',
  `total_qty` int NOT NULL DEFAULT '0',
  `total_amount` decimal(12,2) NOT NULL DEFAULT '0.00',
  `audit_status` varchar(16) NOT NULL DEFAULT 'PENDING' COMMENT 'PENDING/APPROVED/REJECTED',
  `audit_by` bigint DEFAULT NULL,
  `audit_time` datetime DEFAULT NULL,
  `audit_remark` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  `version` int NOT NULL DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_report_no` (`report_no`),
  KEY `idx_channel_order_channel` (`channel_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='渠道报单';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_channel_order`
--

LOCK TABLES `t_channel_order` WRITE;
/*!40000 ALTER TABLE `t_channel_order` DISABLE KEYS */;
INSERT INTO `t_channel_order` VALUES (1,'RP202610120001',1,'DD202610120002',20,2660.00,'APPROVED',1,'2026-10-12 14:10:00','额度充足，审核通过','2026-10-18 20:50:56','2026-10-18 21:31:00',0,0,NULL),(2,'RP202610180002',2,NULL,50,6400.00,'PENDING',NULL,NULL,NULL,'2026-10-18 20:50:56','2026-10-18 21:31:00',0,1,NULL);
/*!40000 ALTER TABLE `t_channel_order` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `t_channel_order_item`
--

DROP TABLE IF EXISTS `t_channel_order_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_channel_order_item` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `report_no` varchar(64) NOT NULL,
  `channel_id` bigint NOT NULL,
  `product_id` bigint NOT NULL,
  `sku_id` bigint NOT NULL,
  `sku_name` varchar(128) NOT NULL,
  `channel_price` decimal(12,2) NOT NULL DEFAULT '0.00' COMMENT '渠道专属价',
  `qty` int NOT NULL DEFAULT '1',
  `amount` decimal(12,2) NOT NULL DEFAULT '0.00',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  `version` int NOT NULL DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_channel_item_report` (`report_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='渠道报单明细';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_channel_order_item`
--

LOCK TABLES `t_channel_order_item` WRITE;
/*!40000 ALTER TABLE `t_channel_order_item` DISABLE KEYS */;
/*!40000 ALTER TABLE `t_channel_order_item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `t_channel_quota_log`
--

DROP TABLE IF EXISTS `t_channel_quota_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_channel_quota_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `channel_id` bigint NOT NULL,
  `change_type` varchar(16) NOT NULL COMMENT 'OCCUPY/RELEASE/ADJUST',
  `amount` decimal(14,2) NOT NULL DEFAULT '0.00',
  `before_quota` decimal(14,2) NOT NULL DEFAULT '0.00',
  `after_quota` decimal(14,2) NOT NULL DEFAULT '0.00',
  `biz_no` varchar(64) DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  `version` int NOT NULL DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_quota_channel` (`channel_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='渠道额度流水';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_channel_quota_log`
--

LOCK TABLES `t_channel_quota_log` WRITE;
/*!40000 ALTER TABLE `t_channel_quota_log` DISABLE KEYS */;
INSERT INTO `t_channel_quota_log` VALUES (1,1,'INCREASE',50000.00,0.00,50000.00,'SYS_INIT','2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL),(2,1,'OCCUPY',12000.00,50000.00,38000.00,'DD202610120002','2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL),(3,2,'INCREASE',20000.00,0.00,20000.00,'SYS_INIT','2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL);
/*!40000 ALTER TABLE `t_channel_quota_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `t_channel_relation`
--

DROP TABLE IF EXISTS `t_channel_relation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_channel_relation` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `channel_id` bigint NOT NULL,
  `parent_id` bigint NOT NULL DEFAULT '0',
  `path` varchar(512) NOT NULL DEFAULT '' COMMENT '0/1/5 形式祖先链',
  `level` int NOT NULL DEFAULT '1',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  `version` int NOT NULL DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_relation_channel` (`channel_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='渠道下级关系';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_channel_relation`
--

LOCK TABLES `t_channel_relation` WRITE;
/*!40000 ALTER TABLE `t_channel_relation` DISABLE KEYS */;
INSERT INTO `t_channel_relation` VALUES (1,1,0,'/1/',1,'2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL),(2,2,1,'/1/2/',2,'2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL);
/*!40000 ALTER TABLE `t_channel_relation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `t_commission`
--

DROP TABLE IF EXISTS `t_commission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_commission` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `commission_no` varchar(64) NOT NULL,
  `channel_id` bigint NOT NULL COMMENT '受益人',
  `from_channel_id` bigint DEFAULT NULL COMMENT '产生方（下级/转介绍）',
  `order_no` varchar(64) NOT NULL,
  `commission_type` varchar(16) NOT NULL DEFAULT 'DISTRIBUTION' COMMENT 'DISTRIBUTION 分销 / REFERRAL 转介绍',
  `base_amount` decimal(12,2) NOT NULL DEFAULT '0.00' COMMENT '计佣基数',
  `rate` decimal(5,2) NOT NULL DEFAULT '0.00' COMMENT '比例快照（落库留痕）',
  `amount` decimal(12,2) NOT NULL DEFAULT '0.00',
  `settle_status` varchar(16) NOT NULL DEFAULT 'PENDING' COMMENT 'PENDING/SETTLED/INVALID',
  `settle_no` varchar(64) DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  `version` int NOT NULL DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_commission_no` (`commission_no`),
  KEY `idx_commission_channel` (`channel_id`),
  KEY `idx_commission_order` (`order_no`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='佣金/返佣';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_commission`
--

LOCK TABLES `t_commission` WRITE;
/*!40000 ALTER TABLE `t_commission` DISABLE KEYS */;
INSERT INTO `t_commission` VALUES (1,'CM202610100001',1,NULL,'DD202610100001','SALE',398.00,8.00,31.84,'SETTLED','ST202610010001','2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL),(2,'CM202610120002',1,NULL,'DD202610120002','SALE',2660.00,8.00,212.80,'PENDING',NULL,'2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL),(3,'CM202610120003',1,2,'DD202610120002','REFERRAL',2660.00,3.00,79.80,'PENDING',NULL,'2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL);
/*!40000 ALTER TABLE `t_commission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `t_order`
--

DROP TABLE IF EXISTS `t_order`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_order` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_no` varchar(64) NOT NULL,
  `member_id` bigint NOT NULL,
  `biz_mode` varchar(16) NOT NULL DEFAULT 'RETAIL' COMMENT 'RETAIL 自营 / WHOLESALE 批发',
  `channel_id` bigint DEFAULT NULL COMMENT '批发归属渠道商',
  `order_status` varchar(24) NOT NULL DEFAULT 'UNPAID' COMMENT 'UNPAID/PAID/SORTING/PACKED/SHIPPED/RECEIVED/COMPLETED/CANCELLED/REFUNDING/REFUNDED',
  `pay_status` varchar(16) NOT NULL DEFAULT 'UNPAID' COMMENT 'UNPAID/PAID/REFUNDED',
  `total_amount` decimal(12,2) NOT NULL DEFAULT '0.00',
  `discount_amount` decimal(12,2) NOT NULL DEFAULT '0.00',
  `freight_amount` decimal(12,2) NOT NULL DEFAULT '0.00' COMMENT '冷链运费',
  `pay_amount` decimal(12,2) NOT NULL DEFAULT '0.00',
  `coupon_id` bigint DEFAULT NULL,
  `pay_type` varchar(16) DEFAULT NULL COMMENT 'WECHAT/ALIPAY/BALANCE',
  `pay_time` datetime DEFAULT NULL,
  `receiver_name` varchar(64) DEFAULT NULL,
  `receiver_mobile` varchar(20) DEFAULT NULL,
  `receiver_address` varchar(512) DEFAULT NULL,
  `remark` varchar(255) DEFAULT NULL,
  `expire_time` datetime DEFAULT NULL COMMENT '未支付超时时间（延迟队列）',
  `cancel_reason` varchar(255) DEFAULT NULL,
  `source` varchar(16) NOT NULL DEFAULT 'MINIAPP' COMMENT 'MINIAPP/H5/PC/ADMIN/CHANNEL',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  `version` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_order_no` (`order_no`),
  KEY `idx_order_member` (`member_id`),
  KEY `idx_order_status` (`order_status`),
  KEY `idx_order_channel` (`channel_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='订单（自营+批发）';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_order`
--

LOCK TABLES `t_order` WRITE;
/*!40000 ALTER TABLE `t_order` DISABLE KEYS */;
INSERT INTO `t_order` VALUES (1,'DD202610100001',1,'RETAIL',NULL,'PAID','PAID',398.00,0.00,0.00,398.00,NULL,'WECHAT','2026-10-10 10:05:00','张伟','13800000001','江西省南昌市红谷滩区赣江中大道 100 号','小程序自营单','2026-10-10 10:30:00',NULL,'MINIAPP','2026-10-18 20:50:56','2026-10-18 21:31:00',0,0),(2,'DD202610120002',2,'WHOLESALE',1,'SHIPPED','PAID',2660.00,0.00,30.00,2690.00,NULL,'WECHAT','2026-10-12 14:20:00','王经理','13900000001','江西省南昌市西湖区洪城大市场 A 区 12 号','渠道批发单','2026-10-12 15:00:00',NULL,'CHANNEL','2026-10-18 20:50:56','2026-10-18 20:50:56',0,0),(3,'DD202610180003',3,'RETAIL',NULL,'UNPAID','UNPAID',258.00,0.00,0.00,258.00,NULL,NULL,NULL,'老表张三','13800000003','江西省九江市浔阳区滨江路 26 号','待支付，超时自动取消','2026-10-18 21:00:00',NULL,'H5','2026-10-18 20:50:56','2026-10-18 20:50:56',0,0);
/*!40000 ALTER TABLE `t_order` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `t_order_delivery`
--

DROP TABLE IF EXISTS `t_order_delivery`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_order_delivery` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_no` varchar(64) NOT NULL,
  `express_company` varchar(32) NOT NULL DEFAULT 'SF' COMMENT '顺丰冷链',
  `express_no` varchar(64) DEFAULT NULL COMMENT '运单号',
  `cold_chain` tinyint NOT NULL DEFAULT '1' COMMENT '是否冷链',
  `pack_check` varchar(512) DEFAULT NULL COMMENT '鲜活打包核验结果（公母/重量）',
  `packer_id` bigint DEFAULT NULL COMMENT '打包/发货员',
  `ship_status` varchar(24) NOT NULL DEFAULT 'WAIT' COMMENT 'WAIT/SORTING/PACKED/OUTBOUND/SHIPPED/IN_TRANSIT/SIGNED/EXCEPTION',
  `track_json` text COMMENT '顺丰轨迹缓存',
  `express_print_time` datetime DEFAULT NULL COMMENT '快递单打印时间',
  `outbound_time` datetime DEFAULT NULL,
  `ship_time` datetime DEFAULT NULL,
  `signed_time` datetime DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  `version` int NOT NULL DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_delivery_order` (`order_no`),
  KEY `idx_delivery_express` (`express_no`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='冷链物流';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_order_delivery`
--

LOCK TABLES `t_order_delivery` WRITE;
/*!40000 ALTER TABLE `t_order_delivery` DISABLE KEYS */;
INSERT INTO `t_order_delivery` VALUES (1,'DD202610100001','顺丰速运','SF1234567890123',1,'公母:MIXED;重量档:3.0-3.4两;只数:8;鲜活度:5',1,'SIGNED',NULL,'2026-10-10 15:30:00','2026-10-10 15:40:00','2026-10-10 16:00:00','2026-10-11 10:20:00','2026-10-18 20:55:16','2026-10-18 20:55:16',0,0,NULL),(2,'DD202610120002','顺丰速运','SF9876543210987',1,'公母:MALE+FEMALE;重量档:2.0-2.4两;只数:20;鲜活度:5',1,'SHIPPED',NULL,'2026-10-12 18:10:00','2026-10-12 18:20:00','2026-10-12 18:40:00',NULL,'2026-10-18 20:55:16','2026-10-18 20:55:16',0,0,NULL);
/*!40000 ALTER TABLE `t_order_delivery` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `t_order_item`
--

DROP TABLE IF EXISTS `t_order_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_order_item` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_no` varchar(64) NOT NULL,
  `order_id` bigint NOT NULL,
  `product_id` bigint NOT NULL,
  `sku_id` bigint NOT NULL,
  `product_name` varchar(128) NOT NULL,
  `sku_name` varchar(128) NOT NULL,
  `spec_desc` varchar(128) DEFAULT NULL COMMENT '公母/重量档/只数',
  `price` decimal(12,2) NOT NULL DEFAULT '0.00',
  `qty` int NOT NULL DEFAULT '1',
  `amount` decimal(12,2) NOT NULL DEFAULT '0.00',
  `image` varchar(512) DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  `version` int NOT NULL DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_order_item_order` (`order_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='订单明细';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_order_item`
--

LOCK TABLES `t_order_item` WRITE;
/*!40000 ALTER TABLE `t_order_item` DISABLE KEYS */;
INSERT INTO `t_order_item` VALUES (1,'DD202610100001',1,1,1,'鄱阳湖大闸蟹·精品礼盒','精品礼盒 3.0-3.4两 公母各4只','3.0-3.4两 / 公母各4只',398.00,1,398.00,NULL,'2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL),(2,'DD202610120002',2,3,3,'鄱阳湖湖蟹·批发大宗','批发 公蟹 2.0-2.4两 50只','2.0-2.4两 / 公蟹 50只',128.00,10,1280.00,NULL,'2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL),(3,'DD202610120002',2,3,4,'鄱阳湖湖蟹·批发大宗','批发 母蟹 2.0-2.4两 50只','2.0-2.4两 / 母蟹 50只',138.00,10,1380.00,NULL,'2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL),(4,'DD202610180003',3,2,2,'鄱阳湖生态大闸蟹·家庭装','家庭装 2.5两 10只','2.5-2.9两 / 10只',258.00,1,258.00,NULL,'2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL);
/*!40000 ALTER TABLE `t_order_item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `t_payment`
--

DROP TABLE IF EXISTS `t_payment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_payment` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `pay_no` varchar(64) NOT NULL COMMENT '平台支付单号',
  `order_no` varchar(64) NOT NULL,
  `pay_type` varchar(16) NOT NULL COMMENT 'WECHAT/ALIPAY/BALANCE',
  `trade_no` varchar(128) DEFAULT NULL COMMENT '第三方交易号',
  `amount` decimal(12,2) NOT NULL DEFAULT '0.00',
  `pay_status` varchar(16) NOT NULL DEFAULT 'UNPAID' COMMENT 'UNPAID/SUCCESS/FAIL/REFUND',
  `notify_raw` text COMMENT '回调原文',
  `refund_amount` decimal(12,2) NOT NULL DEFAULT '0.00',
  `pay_time` datetime DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  `version` int NOT NULL DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_pay_no` (`pay_no`),
  UNIQUE KEY `uk_payment_trade` (`pay_type`,`trade_no`),
  KEY `idx_payment_order` (`order_no`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='支付流水';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_payment`
--

LOCK TABLES `t_payment` WRITE;
/*!40000 ALTER TABLE `t_payment` DISABLE KEYS */;
INSERT INTO `t_payment` VALUES (1,'PAY202610100001','DD202610100001','WECHAT','4200001234567890',398.00,'SUCCESS','{\"trade_state\":\"SUCCESS\",\"demo\":true}',0.00,'2026-10-10 10:05:00','2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL),(2,'PAY202610120002','DD202610120002','WECHAT','4200009876543210',2690.00,'SUCCESS','{\"trade_state\":\"SUCCESS\",\"demo\":true}',0.00,'2026-10-12 14:20:00','2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL);
/*!40000 ALTER TABLE `t_payment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `t_review`
--

DROP TABLE IF EXISTS `t_review`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_review` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_no` varchar(64) NOT NULL,
  `member_id` bigint NOT NULL,
  `product_id` bigint NOT NULL,
  `sku_id` bigint DEFAULT NULL,
  `score` tinyint NOT NULL DEFAULT '5' COMMENT '1-5',
  `content` varchar(1024) DEFAULT NULL COMMENT '敏感词过滤',
  `images` text,
  `survival_rate` tinyint DEFAULT NULL COMMENT '鲜活度（1-5）',
  `is_show` tinyint NOT NULL DEFAULT '0',
  `reply_content` varchar(1024) DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  `version` int NOT NULL DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_review_order` (`order_no`),
  KEY `idx_review_product` (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='收货评价';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_review`
--

LOCK TABLES `t_review` WRITE;
/*!40000 ALTER TABLE `t_review` DISABLE KEYS */;
INSERT INTO `t_review` VALUES (1,'DD202610100001',1,1,1,5,'螃蟹很鲜活，包装扎实，公母比例准确，家里老人很满意。',NULL,100,1,'感谢支持，祝您生活愉快！','2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL),(2,'DD202610120002',2,3,3,4,'批发走量，整体品质稳定，个别规格略小，可以接受。',NULL,96,0,NULL,'2026-10-18 20:50:56','2026-10-18 20:50:56',0,0,NULL);
/*!40000 ALTER TABLE `t_review` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `t_settlement`
--

DROP TABLE IF EXISTS `t_settlement`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_settlement` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `settle_no` varchar(64) NOT NULL,
  `channel_id` bigint NOT NULL,
  `period_start` date NOT NULL,
  `period_end` date NOT NULL,
  `order_amount` decimal(14,2) NOT NULL DEFAULT '0.00' COMMENT '期间订单额',
  `commission_amount` decimal(14,2) NOT NULL DEFAULT '0.00' COMMENT '期间佣金',
  `settle_amount` decimal(14,2) NOT NULL DEFAULT '0.00' COMMENT '应结算金额',
  `status` varchar(16) NOT NULL DEFAULT 'DRAFT' COMMENT 'DRAFT/CONFIRMED/PAID',
  `confirm_time` datetime DEFAULT NULL,
  `pay_time` datetime DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  `version` int NOT NULL DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_settle_no` (`settle_no`),
  KEY `idx_settle_channel` (`channel_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='对账结算单';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_settlement`
--

LOCK TABLES `t_settlement` WRITE;
/*!40000 ALTER TABLE `t_settlement` DISABLE KEYS */;
INSERT INTO `t_settlement` VALUES (1,'ST202610010001',1,'2026-09-01','2026-09-30',12800.00,1024.00,1024.00,'CONFIRMED','2026-10-02 10:00:00','2026-10-03 15:00:00','2026-10-18 20:50:56','2026-10-18 22:04:57',0,0,NULL);
/*!40000 ALTER TABLE `t_settlement` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'poyang_crab'
--

--
-- Dumping routines for database 'poyang_crab'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-18 22:40:55
