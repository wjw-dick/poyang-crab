-- =============================================================================
-- 可选演示数据（默认不执行）
-- =============================================================================
-- 用途：本地 / 演示环境快速让各列表页有数据，便于逐项验收后台功能
--       （商品、库存、会员、卡券、积分储值、订单、支付流水、评价、
--         渠道档案、报单审核、佣金规则、对账结算、文章、渠道申请）。
--
-- 执行方式（两种任选其一）：
--   1) powershell -NoProfile -ExecutionPolicy Bypass -File scripts\init-db.ps1 -Force -WithDemo
--   2) mysql -upoyang_crab -p poyang_crab < sql/98_demo_data.sql
--
-- 约定：
--   * 全部使用固定主键 + INSERT IGNORE，可重复执行（已存在则跳过，不覆盖线上改动）
--   * 生产环境请勿执行本文件
--   * 金额单位：元；比例单位：百分数（8.00 表示 8%）
-- =============================================================================

SET NAMES utf8mb4;

-- -----------------------------------------------------------------------------
-- 前置：演示数据使用固定主键。若这些 id 曾经被逻辑删除过（deleted=1，
-- 例如早期用界面做增删测试后删除的记录），INSERT IGNORE 会因主键冲突被整体跳过，
-- 结果演示数据插不进去、列表依旧是空的。
-- 这里只对下面明确列出的演示 id、且已被逻辑删除的行做物理清理，腾出主键；
-- 对正常数据（deleted=0）不做任何改动，其它 id 也一概不动。
-- -----------------------------------------------------------------------------
DELETE FROM `product_category`     WHERE `deleted`=1 AND `id` IN (1,2,3);
DELETE FROM `product`              WHERE `deleted`=1 AND `id` IN (1,2,3);
DELETE FROM `product_spec`         WHERE `deleted`=1 AND `id` IN (1,2,3,4);
DELETE FROM `product_sku`          WHERE `deleted`=1 AND `id` IN (1,2,3,4);
DELETE FROM `stock`                WHERE `deleted`=1 AND `id` IN (1,2,3,4);
DELETE FROM `member`               WHERE `deleted`=1 AND `id` IN (1,2,3);
DELETE FROM `t_channel`            WHERE `deleted`=1 AND `id` IN (1,2);
DELETE FROM `t_channel_relation`   WHERE `deleted`=1 AND `id` IN (1,2);
DELETE FROM `t_channel_quota_log`  WHERE `deleted`=1 AND `id` IN (1,2,3);
DELETE FROM `t_order`              WHERE `deleted`=1 AND `id` IN (1,2,3);
DELETE FROM `t_order_delivery`     WHERE `deleted`=1 AND `id` IN (1,2);
DELETE FROM `t_order_item`         WHERE `deleted`=1 AND `id` IN (1,2,3,4);
DELETE FROM `t_payment`            WHERE `deleted`=1 AND `id` IN (1,2);
DELETE FROM `t_review`             WHERE `deleted`=1 AND `id` IN (1,2);
DELETE FROM `t_channel_order`      WHERE `deleted`=1 AND `id` IN (1,2);
DELETE FROM `t_commission`         WHERE `deleted`=1 AND `id` IN (1,2,3);
DELETE FROM `t_settlement`         WHERE `deleted`=1 AND `id` IN (1);
DELETE FROM `member_coupon`        WHERE `deleted`=1 AND `id` IN (1,2);
DELETE FROM `member_coupon_log`    WHERE `deleted`=1 AND `id` IN (1);
DELETE FROM `member_point_log`     WHERE `deleted`=1 AND `id` IN (1,2);
DELETE FROM `member_balance_log`   WHERE `deleted`=1 AND `id` IN (1,2);
DELETE FROM `cms_channel_apply`    WHERE `deleted`=1 AND `id` IN (1);
DELETE FROM `cms_article`          WHERE `deleted`=1 AND `id` IN (1,2,3);

-- ---------------------------------------------------------------- 商品分类
INSERT IGNORE INTO `product_category` (`id`,`parent_id`,`category_name`,`category_name_en`,`sort`,`status`) VALUES
  (1,0,'鲜活湖蟹','Live Crab',1,1),
  (2,0,'礼盒装','Gift Box',2,1),
  (3,0,'批发大宗','Bulk Wholesale',3,1);

-- ---------------------------------------------------------------- 商品 / 规格 / SKU
-- sell_mode：RETAIL 仅自营 / WHOLESALE 仅批发 / BOTH 自营+批发（批发走渠道端）
INSERT IGNORE INTO `product`
  (`id`,`product_no`,`category_id`,`product_name`,`product_name_en`,`main_image`,`images`,`detail_html`,`origin`,
   `sell_mode`,`retail_price`,`wholesale_price`,`min_order_qty`,`status`,`sort`,`remark`) VALUES
  (1,'P2026001',2,'鄱阳湖大闸蟹·精品礼盒（3.0-3.4两 8只）','Poyang Lake Hairy Crab Premium Gift Box','','[]',
   '<p>精选鄱阳湖核心湖区大闸蟹，公母各 4 只，3.0-3.4 两规格，全程冷链直发。</p>','江西·鄱阳湖',
   'RETAIL',398.00,328.00,10,1,1,'年货季主推'),
  (2,'P2026002',1,'鄱阳湖生态大闸蟹·家庭装（2.5两 10只）','Poyang Lake Eco Crab Family Pack','','[]',
   '<p>生态养殖湖区直供，2.5 两左右，10 只家庭装，适合日常家宴。</p>','江西·鄱阳湖',
   'BOTH',258.00,198.00,20,1,2,'日常走量款'),
  (3,'P2026003',3,'鄱阳湖湖蟹·批发大宗（2.0两 起）','Poyang Lake Crab Bulk Wholesale','','[]',
   '<p>面向渠道商批发，公母分筐，支持按筐议价与信用额度结算。</p>','江西·鄱阳湖',
   'WHOLESALE',168.00,128.00,100,1,3,'渠道批发专用');

INSERT IGNORE INTO `product_spec`
  (`id`,`product_id`,`crab_sex`,`weight_level`,`weight_min`,`weight_max`,`piece_count`,`pack_type`) VALUES
  (1,1,'MIXED','3.0-3.4两',3.00,3.40,8,'礼盒'),
  (2,2,'MIXED','2.5-2.9两',2.50,2.90,10,'泡沫箱'),
  (3,3,'MALE','2.0-2.4两',2.00,2.40,50,'批发筐'),
  (4,3,'FEMALE','2.0-2.4两',2.00,2.40,50,'批发筐');

INSERT IGNORE INTO `product_sku`
  (`id`,`product_id`,`spec_id`,`sku_no`,`sku_name`,`retail_price`,`wholesale_price`,`cost_price`,`status`) VALUES
  (1,1,1,'SKU2026001','精品礼盒 3.0-3.4两 公母各4只',398.00,328.00,210.00,1),
  (2,2,2,'SKU2026002','家庭装 2.5两 10只',258.00,198.00,140.00,1),
  (3,3,3,'SKU2026003','批发 公蟹 2.0-2.4两 50只',168.00,128.00,90.00,1),
  (4,3,4,'SKU2026004','批发 母蟹 2.0-2.4两 50只',178.00,138.00,95.00,1);

-- ---------------------------------------------------------------- 库存（自营 + 批发共用同一 SKU）
INSERT IGNORE INTO `stock` (`id`,`sku_id`,`warehouse`,`total_qty`,`available_qty`,`locked_qty`,`warn_qty`) VALUES
  (1,1,'鄱阳湖主仓',300,280,20,30),
  (2,2,'鄱阳湖主仓',200,180,20,30),
  (3,3,'南昌中转仓',500,450,50,100),
  (4,4,'南昌中转仓',500,470,30,100);

-- ---------------------------------------------------------------- 会员（UnionID 三端互通）
INSERT IGNORE INTO `member`
  (`id`,`union_id`,`open_id_mini`,`nickname`,`mobile`,`gender`,`member_level`,`points`,`balance`,`status`) VALUES
  (1,'oU_demo_union_001','oMini_demo_001','鄱阳湖畔的吃货','13800000001',1,'GOLD',1280,200.00,1),
  (2,'oU_demo_union_002','oMini_demo_002','蟹老板','13800000002',1,'NORMAL',120,0.00,1),
  (3,'oU_demo_union_003','oMini_demo_003','老表张三','13800000003',2,'SILVER',560,50.00,1);

-- ---------------------------------------------------------------- 渠道商（两级分销）
INSERT IGNORE INTO `t_channel`
  (`id`,`channel_no`,`channel_name`,`contact_name`,`contact_mobile`,`union_id`,`channel_level`,`parent_id`,
   `commission_rate`,`referral_rate`,`credit_quota`,`used_quota`,`status`,`remark`) VALUES
  (1,'CH2026001','南昌蟹逅商贸有限公司','王经理','13900000001','oU_channel_001','L1',0,8.00,3.00,50000.00,12000.00,'NORMAL','区域一级经销商'),
  (2,'CH2026002','九江鲜生优选','李总','13900000002','oU_channel_002','L2',1,5.00,2.00,20000.00,3000.00,'NORMAL','九江二级经销商');

INSERT IGNORE INTO `t_channel_relation` (`id`,`channel_id`,`parent_id`,`path`,`level`) VALUES
  (1,1,0,'/1/',1),
  (2,2,1,'/1/2/',2);

INSERT IGNORE INTO `t_channel_quota_log`
  (`id`,`channel_id`,`change_type`,`amount`,`before_quota`,`after_quota`,`biz_no`) VALUES
  (1,1,'INCREASE',50000.00,0.00,50000.00,'SYS_INIT'),
  (2,1,'OCCUPY',12000.00,50000.00,38000.00,'DD202610120002'),
  (3,2,'INCREASE',20000.00,0.00,20000.00,'SYS_INIT');

-- ---------------------------------------------------------------- 订单（自营 + 批发）
INSERT IGNORE INTO `t_order`
  (`id`,`order_no`,`member_id`,`biz_mode`,`channel_id`,`order_status`,`pay_status`,`total_amount`,`discount_amount`,
   `freight_amount`,`pay_amount`,`pay_type`,`pay_time`,`receiver_name`,`receiver_mobile`,`receiver_address`,
   `expire_time`,`source`,`remark`) VALUES
  (1,'DD202610100001',1,'RETAIL',NULL,'COMPLETED','PAID',398.00,0.00,0.00,398.00,'WECHAT','2026-10-10 10:05:00',
   '张伟','13800000001','江西省南昌市红谷滩区赣江中大道 100 号','2026-10-10 10:30:00','MINIAPP','小程序自营单'),
  (2,'DD202610120002',2,'WHOLESALE',1,'SHIPPED','PAID',2660.00,0.00,30.00,2690.00,'WECHAT','2026-10-12 14:20:00',
   '王经理','13900000001','江西省南昌市西湖区洪城大市场 A 区 12 号','2026-10-12 15:00:00','CHANNEL','渠道批发单'),
  (3,'DD202610180003',3,'RETAIL',NULL,'UNPAID','UNPAID',258.00,0.00,0.00,258.00,NULL,NULL,
   '老表张三','13800000003','江西省九江市浔阳区滨江路 26 号','2026-10-18 21:00:00','H5','待支付，超时自动取消');

INSERT IGNORE INTO `t_order_item`
  (`id`,`order_no`,`order_id`,`product_id`,`sku_id`,`product_name`,`sku_name`,`spec_desc`,`price`,`qty`,`amount`) VALUES
  (1,'DD202610100001',1,1,1,'鄱阳湖大闸蟹·精品礼盒','精品礼盒 3.0-3.4两 公母各4只','3.0-3.4两 / 公母各4只',398.00,1,398.00),
  (2,'DD202610120002',2,3,3,'鄱阳湖湖蟹·批发大宗','批发 公蟹 2.0-2.4两 50只','2.0-2.4两 / 公蟹 50只',128.00,10,1280.00),
  (3,'DD202610120002',2,3,4,'鄱阳湖湖蟹·批发大宗','批发 母蟹 2.0-2.4两 50只','2.0-2.4两 / 母蟹 50只',138.00,10,1380.00),
  (4,'DD202610180003',3,2,2,'鄱阳湖生态大闸蟹·家庭装','家庭装 2.5两 10只','2.5-2.9两 / 10只',258.00,1,258.00);

-- ---------------------------------------------------------------- 冷链发货单（出库发货 / 物流轨迹）
INSERT IGNORE INTO `t_order_delivery`
  (`id`,`order_no`,`express_company`,`express_no`,`cold_chain`,`pack_check`,`packer_id`,`ship_status`,
   `express_print_time`,`outbound_time`,`ship_time`,`signed_time`) VALUES
  (1,'DD202610100001','顺丰速运','SF1234567890123',1,'公母:MIXED;重量档:3.0-3.4两;只数:8;鲜活度:5',1,'SIGNED',
   '2026-10-10 15:30:00','2026-10-10 15:40:00','2026-10-10 16:00:00','2026-10-11 10:20:00'),
  (2,'DD202610120002','顺丰速运','SF9876543210987',1,'公母:MALE+FEMALE;重量档:2.0-2.4两;只数:20;鲜活度:5',1,'SHIPPED',
   '2026-10-12 18:10:00','2026-10-12 18:20:00','2026-10-12 18:40:00',NULL);

-- ---------------------------------------------------------------- 支付流水
INSERT IGNORE INTO `t_payment`
  (`id`,`pay_no`,`order_no`,`pay_type`,`trade_no`,`amount`,`pay_status`,`refund_amount`,`pay_time`,`notify_raw`) VALUES
  (1,'PAY202610100001','DD202610100001','WECHAT','4200001234567890',398.00,'SUCCESS',0.00,'2026-10-10 10:05:00',
   '{"trade_state":"SUCCESS","demo":true}'),
  (2,'PAY202610120002','DD202610120002','WECHAT','4200009876543210',2690.00,'SUCCESS',0.00,'2026-10-12 14:20:00',
   '{"trade_state":"SUCCESS","demo":true}');

-- ---------------------------------------------------------------- 评价（含鲜活度）
INSERT IGNORE INTO `t_review`
  (`id`,`order_no`,`member_id`,`product_id`,`sku_id`,`score`,`content`,`survival_rate`,`is_show`,`reply_content`) VALUES
  (1,'DD202610100001',1,1,1,5,'螃蟹很鲜活，包装扎实，公母比例准确，家里老人很满意。',100,1,'感谢支持，祝您生活愉快！'),
  (2,'DD202610120002',2,3,3,4,'批发走量，整体品质稳定，个别规格略小，可以接受。',96,0,NULL);

-- ---------------------------------------------------------------- 渠道报单（审核）
INSERT IGNORE INTO `t_channel_order`
  (`id`,`report_no`,`channel_id`,`order_no`,`total_qty`,`total_amount`,`audit_status`,`audit_by`,`audit_time`,`audit_remark`) VALUES
  (1,'RP202610120001',1,'DD202610120002',20,2660.00,'APPROVED',1,'2026-10-12 14:10:00','额度充足，审核通过'),
  (2,'RP202610180002',2,NULL,50,6400.00,'PENDING',NULL,NULL,NULL);

-- ---------------------------------------------------------------- 佣金（分销 + 转介绍）
INSERT IGNORE INTO `t_commission`
  (`id`,`commission_no`,`channel_id`,`from_channel_id`,`order_no`,`commission_type`,`base_amount`,`rate`,`amount`,
   `settle_status`,`settle_no`) VALUES
  (1,'CM202610100001',1,NULL,'DD202610100001','SALE',398.00,8.00,31.84,'SETTLED','ST202610010001'),
  (2,'CM202610120002',1,NULL,'DD202610120002','SALE',2660.00,8.00,212.80,'PENDING',NULL),
  (3,'CM202610120003',1,2,'DD202610120002','REFERRAL',2660.00,3.00,79.80,'PENDING',NULL);

-- ---------------------------------------------------------------- 对账结算
INSERT IGNORE INTO `t_settlement`
  (`id`,`settle_no`,`channel_id`,`period_start`,`period_end`,`order_amount`,`commission_amount`,`settle_amount`,
   `status`,`confirm_time`,`pay_time`) VALUES
  (1,'ST202610010001',1,'2026-09-01','2026-09-30',12800.00,1024.00,1024.00,'CONFIRMED','2026-10-02 10:00:00','2026-10-03 15:00:00');

-- ---------------------------------------------------------------- 会员卡券 / 积分 / 储值
INSERT IGNORE INTO `member_coupon`
  (`id`,`coupon_name`,`coupon_type`,`threshold`,`discount_amount`,`discount_rate`,`total_qty`,`used_qty`,
   `valid_start`,`valid_end`,`status`) VALUES
  (1,'新客立减 20 元','CASH',199.00,20.00,NULL,1000,156,'2026-09-01 00:00:00','2026-12-31 23:59:59',1),
  (2,'礼盒专享 9 折','DISCOUNT',500.00,NULL,90.00,500,88,'2026-09-15 00:00:00','2026-10-15 23:59:59',1);

INSERT IGNORE INTO `member_coupon_log` (`id`,`coupon_id`,`member_id`,`status`,`order_no`,`used_time`) VALUES
  (1,1,1,'USED','DD202610100001','2026-10-10 10:00:00');

INSERT IGNORE INTO `member_point_log`
  (`id`,`member_id`,`change_type`,`points`,`before_points`,`after_points`,`source`,`biz_no`) VALUES
  (1,1,'EARN',398,882,1280,'订单消费返积分','DD202610100001'),
  (2,3,'EARN',60,500,560,'每日签到','SIGN20261018');

INSERT IGNORE INTO `member_balance_log`
  (`id`,`member_id`,`change_type`,`amount`,`before_balance`,`after_balance`,`biz_no`) VALUES
  (1,1,'EARN',200.00,0.00,200.00,'RECHARGE20261001'),
  (2,3,'EARN',50.00,0.00,50.00,'RECHARGE20261002');

-- ---------------------------------------------------------------- 渠道商申请（PC 官网招商表单落库）
INSERT IGNORE INTO `cms_channel_apply`
  (`id`,`company_name`,`contact_name`,`contact_mobile`,`region`,`intention`,`audit_status`,`audit_remark`) VALUES
  (1,'南昌蟹逅商贸有限公司','王经理','13900000001','江西省南昌市','区域独家分销，年采购量约 5000 斤','PENDING',NULL);

-- ---------------------------------------------------------------- CMS 文章
INSERT IGNORE INTO `cms_article`
  (`id`,`category_id`,`title`,`title_en`,`summary`,`summary_en`,`cover`,`content_html`,`content_html_en`,
   `seo_title`,`seo_keywords`,`seo_desc`,`is_top`,`status`,`publish_time`,`view_count`)
SELECT 1, c.`id`,
  '鄱阳湖大闸蟹的四季：从投苗到上桌','Four Seasons of Poyang Lake Hairy Crab',
  '从春天投苗、夏天喂螺蛳，到秋天膏满黄肥，记录一只鄱阳湖大闸蟹的完整生长周期。',
  'From spring seeding to autumn harvest, the full growth cycle of Poyang Lake hairy crab.',
  '',
  '<h3>春季投苗</h3><p>三月水温回升，湖区开始投放蟹苗，选用长江水系优质扣蟹。</p><h3>秋季膏黄</h3><p>九月末至十一月是鄱阳湖大闸蟹的最佳赏味期，公蟹膏腴、母蟹黄满。</p>',
  '<h3>Spring</h3><p>Seeding begins when water temperature rises in March.</p><h3>Autumn</h3><p>Late September to November is the best season.</p>',
  '鄱阳湖大闸蟹的四季 · 螃蟹小公主','鄱阳湖,大闸蟹,养殖,礼盒','鄱阳湖大闸蟹生长周期与最佳赏味期科普。',
  1,'PUBLISHED','2026-10-08 09:00:00',1286
FROM `cms_category` c WHERE c.`category_code`='brand';

INSERT IGNORE INTO `cms_article`
  (`id`,`category_id`,`title`,`title_en`,`summary`,`summary_en`,`cover`,`content_html`,`content_html_en`,
   `seo_title`,`seo_keywords`,`seo_desc`,`is_top`,`status`,`publish_time`,`view_count`)
SELECT 2, c.`id`,
  '凌晨四点的捕捞实景：一网湖蟹如何上岸','Harvest at 4 A.M. on Poyang Lake',
  '跟随捕捞队出湖，记录从起网、分拣、暂养到装车冷链的全过程。',
  'Follow the harvest team and see how crabs are netted, sorted and cold-chain shipped.',
  '',
  '<h3>起网</h3><p>凌晨四点，捕捞船在核心湖区起网，湖蟹即刻进入分拣筐。</p><h3>暂养与分拣</h3><p>上岸后按公母与重量档快速分拣，两小时内完成暂养并装箱。</p>',
  '<h3>Netting</h3><p>Crews net crabs at 4 a.m. in the core lake area.</p><h3>Sorting</h3><p>Crabs are sorted by sex and weight within two hours.</p>',
  '鄱阳湖捕捞实景 · 螃蟹小公主','鄱阳湖,捕捞,分拣,冷链','凌晨捕捞与冷链直发的现场记录。',
  0,'PUBLISHED','2026-10-12 08:30:00',642
FROM `cms_category` c WHERE c.`category_code`='catch';

INSERT IGNORE INTO `cms_article`
  (`id`,`category_id`,`title`,`title_en`,`summary`,`summary_en`,`cover`,`content_html`,`content_html_en`,
   `seo_title`,`seo_keywords`,`seo_desc`,`is_top`,`status`,`publish_time`,`view_count`)
SELECT 3, c.`id`,
  '平台公告：2026 年蟹季售后与鲜活保障说明','Notice: 2026 Season Freshness Guarantee',
  '蟹季售后细则、死蟹赔付标准与冷链时效说明（草稿待发布）。',
  'After-sales rules and freshness compensation policy (draft).',
  '',
  '<p>本公告为草稿，待运营确认后发布。</p>','','平台公告 · 螃蟹小公主','售后,赔付,冷链','蟹季售后与鲜活保障说明。',
  0,'DRAFT',NULL,0
FROM `cms_category` c WHERE c.`category_code`='notice';

-- ---------------------------------------------------------------- 完成
SELECT '演示数据已写入' AS result,
       (SELECT COUNT(*) FROM `product`) AS product_cnt,
       (SELECT COUNT(*) FROM `member`) AS member_cnt,
       (SELECT COUNT(*) FROM `t_order`) AS order_cnt,
       (SELECT COUNT(*) FROM `t_channel`) AS channel_cnt,
       (SELECT COUNT(*) FROM `cms_article`) AS article_cnt;
