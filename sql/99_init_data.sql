-- =============================================================
-- 初始化数据：角色 / 超管账号 / 系统参数 / 语言 / 菜单骨架
-- 默认账号 admin / Admin@123456（BCrypt）—— 上线前必须修改
-- =============================================================
USE `poyang_crab`;

-- 角色（PRO.md 6.2 RBAC 角色表）
INSERT INTO `sys_role` (`role_code`,`role_name`,`data_scope`,`sort`) VALUES
  ('SUPER_ADMIN','超级管理员','ALL',1),
  ('SHOP_MANAGER','店长','ALL',2),
  ('FINANCE','财务','ALL',3),
  ('SHIPPER','仓管/发货员','SELF',4),
  ('CHANNEL','渠道商','CHANNEL',5),
  ('CHANNEL_ADMIN','渠道商管理员','CHANNEL',6),
  ('MEMBER','普通会员','SELF',7)
ON DUPLICATE KEY UPDATE `role_name`=VALUES(`role_name`);

-- 超管（密码：Admin@123456；BCrypt 10 轮哈希已用 spring-security-crypto 校验通过）
INSERT INTO `sys_user` (`username`,`password`,`real_name`,`role_type`,`status`)
VALUES ('admin','$2a$10$MEKdwjLQmNOnsp5HNsYwBuhNMDvIOSzZuVPPgryWy4pT0ro0tiSZS','超级管理员','SUPER_ADMIN',1)
ON DUPLICATE KEY UPDATE `real_name`=VALUES(`real_name`);

INSERT IGNORE INTO `sys_user_role` (`user_id`,`role_id`)
SELECT u.id, r.id FROM `sys_user` u, `sys_role` r WHERE u.username='admin' AND r.role_code='SUPER_ADMIN';

-- 系统全局参数（站点/ICP/客服/微信/支付/存储/业务比例）
INSERT INTO `sys_config` (`config_key`,`config_name`,`config_group`,`config_value`,`value_type`,`is_encrypted`) VALUES
  ('site.name','平台名称','SITE','螃蟹小公主｜鄱阳湖湖蟹','STRING',0),
  ('site.domain','平台域名','SITE','xiegongzhu.com','STRING',0),
  ('site.logo','站点 Logo','SITE','','STRING',0),
  ('site.icp','ICP 备案号','ICP','','STRING',0),
  ('site.copyright','版权信息','SITE','© 螃蟹小公主','STRING',0),
  ('service.hotline','客服热线','SERVICE','400-000-0000','STRING',0),
  ('service.qrcode','客服二维码','SERVICE','','STRING',0),
  ('wechat.mp.appid','服务号 AppID','WECHAT','','STRING',0),
  ('wechat.mp.secret','服务号 Secret','WECHAT','','STRING',1),
  ('wechat.mini.appid','小程序 AppID','WECHAT','','STRING',0),
  ('wechat.mini.secret','小程序 Secret','WECHAT','','STRING',1),
  ('wechat.pay.mchid','微信支付商户号','PAY','','STRING',0),
  ('wechat.pay.apiv3key','微信支付 APIv3 密钥','PAY','','STRING',1),
  ('alipay.appid','支付宝 AppID','PAY','','STRING',0),
  ('alipay.privatekey','支付宝私钥','PAY','','STRING',1),
  ('storage.active.driver','当前对象存储驱动','STORAGE','MINIO','STRING',0),
  ('business.order.expire.minutes','订单未支付超时(分钟)','BUSINESS','30','NUMBER',0),
  ('business.channel.min.order.qty','批发起订量','BUSINESS','10','NUMBER',0),
  ('business.channel.default.commission.rate','渠道默认分销佣金比例(%)','BUSINESS','5.00','NUMBER',0),
  ('business.channel.default.referral.rate','转介绍返佣比例(%)','BUSINESS','2.00','NUMBER',0),
  ('business.channel.default.credit.quota','渠道默认授信额度','BUSINESS','100000.00','NUMBER',0),
  ('business.freight.cold.chain','冷链运费(元)','BUSINESS','0.00','NUMBER',0),
  ('business.agreement.enabled','下单协议弹窗开关','BUSINESS','true','BOOL',0)
ON DUPLICATE KEY UPDATE `config_name`=VALUES(`config_name`);

-- 语言
INSERT INTO `sys_lang` (`lang_code`,`lang_name`,`is_default`,`sort`) VALUES
  ('zh-CN','简体中文',1,1),
  ('en-US','English',0,2)
ON DUPLICATE KEY UPDATE `lang_name`=VALUES(`lang_name`);

-- 词条示例
INSERT INTO `sys_i18n` (`item_key`,`lang_code`,`item_value`) VALUES
  ('site.title','zh-CN','螃蟹小公主 · 鄱阳湖湖蟹'),
  ('site.title','en-US','Princess Crab · Poyang Lake Hairy Crab'),
  ('nav.home','zh-CN','首页'),
  ('nav.home','en-US','Home'),
  ('nav.recruit','zh-CN','招商合作'),
  ('nav.recruit','en-US','Partnership')
ON DUPLICATE KEY UPDATE `item_value`=VALUES(`item_value`);

-- 菜单骨架（ADMIN 平台，供 vue-pure-admin 动态路由）
-- icon 取值必须是 Element Plus 图标组件名（@element-plus/icons-vue，如 Setting/Tools/Money），
-- 与前端 router/index.ts 的 meta.icon 及菜单维护页的图标选择器保持一致。
INSERT INTO `sys_menu` (`id`,`parent_id`,`menu_name`,`platform`,`menu_type`,`path`,`component`,`icon`,`perm`,`sort`) VALUES
  (1,0,'系统管理','ADMIN','DIR','/system','Layout','Setting','system',100),
  (2,1,'系统参数','ADMIN','MENU','/system/config','system/config/index','Tools','system:config:list',1),
  (3,1,'多语言','ADMIN','MENU','/system/i18n','system/i18n/index','Translate','system:i18n:list',2),
  (4,1,'菜单维护','ADMIN','MENU','/system/menu','system/menu/index','Menu','system:menu:list',4),
  (7,1,'字典管理','ADMIN','MENU','/system/dict','system/dict/index','Collection','system:dict:list',3),
  (5,1,'对象存储','ADMIN','MENU','/system/storage','system/storage/index','Cloudy','system:storage:list',5),
  (6,1,'审计日志','ADMIN','MENU','/system/audit','system/audit/index','Notebook','system:audit:list',6),
  (10,0,'商品中心','ADMIN','DIR','/product','Layout','Goods','product',200),
  (11,10,'商品管理','ADMIN','MENU','/product/list','product/list/index','ShoppingBag','product:list',1),
  (12,10,'分类管理','ADMIN','MENU','/product/category','product/category/index','Grid','product:category:list',2),
  (13,10,'库存管理','ADMIN','MENU','/product/stock','product/stock/index','Box','product:stock:list',3),
  (20,0,'交易中心','ADMIN','DIR','/trade','Layout','ShoppingCart','trade',300),
  (21,20,'订单管理','ADMIN','MENU','/trade/order','trade/order/index','List','trade:order:list',1),
  (22,20,'支付流水','ADMIN','MENU','/trade/payment','trade/payment/index','Money','trade:payment:list',2),
  (23,20,'评价管理','ADMIN','MENU','/trade/review','trade/review/index','Star','trade:review:list',3),
  (30,0,'冷链发货端','ADMIN','DIR','/ship','Layout','Van','ship',400),
  (31,30,'待发货分拣','ADMIN','MENU','/ship/wait','ship/wait/index','Sort','ship:wait:list',1),
  (32,30,'打包核验','ADMIN','MENU','/ship/pack','ship/pack/index','Checked','ship:pack:list',2),
  (33,30,'出库发货','ADMIN','MENU','/ship/outbound','ship/outbound/index','Upload','ship:outbound:list',3),
  (40,0,'渠道商管理','ADMIN','DIR','/channel','Layout','User','channel',500),
  (41,40,'渠道档案','ADMIN','MENU','/channel/list','channel/list/index','UserFilled','channel:list',1),
  (42,40,'报单审核','ADMIN','MENU','/channel/report','channel/report/index','EditPen','channel:report:list',2),
  (43,40,'佣金规则','ADMIN','MENU','/channel/commission','channel/commission/index','Coin','channel:commission:list',3),
  (44,40,'对账结算','ADMIN','MENU','/channel/settlement','channel/settlement/index','Files','channel:settlement:list',4),
  (50,0,'会员中心','ADMIN','DIR','/member','Layout','Avatar','member',600),
  (51,50,'会员列表','ADMIN','MENU','/member/list','member/list/index','User','member:list',1),
  (52,50,'卡券管理','ADMIN','MENU','/member/coupon','member/coupon/index','Ticket','member:coupon:list',2),
  (53,50,'积分储值','ADMIN','MENU','/member/assets','member/assets/index','Wallet','member:assets:list',3),
  (60,0,'内容管理','ADMIN','DIR','/cms','Layout','Document','cms',700),
  (61,60,'文章管理','ADMIN','MENU','/cms/article','cms/article/index','Document','cms:article:list',1),
  (62,60,'栏目管理','ADMIN','MENU','/cms/category','cms/category/index','Folder','cms:category:list',2),
  (63,60,'渠道申请','ADMIN','MENU','/cms/apply','cms/apply/index','Promotion','cms:apply:list',3)
ON DUPLICATE KEY UPDATE
  `parent_id`=VALUES(`parent_id`),
  `menu_name`=VALUES(`menu_name`),
  `platform`=VALUES(`platform`),
  `menu_type`=VALUES(`menu_type`),
  `path`=VALUES(`path`),
  `component`=VALUES(`component`),
  `icon`=VALUES(`icon`),
  `perm`=VALUES(`perm`),
  `sort`=VALUES(`sort`);

-- 超管拥有全部菜单
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`)
SELECT r.id, m.id FROM `sys_role` r, `sys_menu` m WHERE r.role_code='SUPER_ADMIN';

-- 字典类型：全站枚举统一在「系统管理 → 字典管理」维护，页面按 item_value 显示 item_label 中文
INSERT INTO `sys_dict` (`dict_type`,`dict_name`) VALUES
  ('order_status','订单状态'),
  ('pay_status','支付状态'),
  ('payment_status','支付流水状态'),
  ('pay_type','支付方式'),
  ('biz_mode','业务模式'),
  ('sell_mode','销售模式'),
  ('order_source','订单来源'),
  ('ship_status','冷链发货状态'),
  ('crab_sex','湖蟹公母'),
  ('channel_level','渠道等级'),
  ('channel_status','渠道状态'),
  ('member_level','会员等级'),
  ('gender','性别'),
  ('audit_status','审核状态'),
  ('settle_status','佣金结算状态'),
  ('settlement_status','结算单状态'),
  ('commission_type','佣金类型'),
  ('change_type','变动类型'),
  ('coupon_type','卡券类型'),
  ('article_status','文章状态'),
  ('status','通用状态'),
  ('yes_no','是否'),
  ('platform','平台'),
  ('menu_type','菜单类型'),
  ('link_type','链接类型')
ON DUPLICATE KEY UPDATE `dict_name`=VALUES(`dict_name`);

-- 字典项：使用固定主键 + ON DUPLICATE KEY UPDATE，可重复执行（不会重复插入）
INSERT INTO `sys_dict_item` (`id`,`dict_type`,`item_label`,`item_value`,`sort`,`status`) VALUES
  -- 订单状态
  (1,'order_status','待支付','UNPAID',1,1),
  (2,'order_status','已支付','PAID',2,1),
  (3,'order_status','分拣中','SORTING',3,1),
  (4,'order_status','已打包','PACKED',4,1),
  (5,'order_status','已发货','SHIPPED',5,1),
  (6,'order_status','已收货','RECEIVED',6,1),
  (7,'order_status','已完成','COMPLETED',7,1),
  (8,'order_status','已取消','CANCELLED',8,1),
  (22,'order_status','退款中','REFUNDING',9,1),
  (23,'order_status','已退款','REFUNDED',10,1),
  -- 支付方式
  (9,'pay_type','微信支付','WECHAT',1,1),
  (10,'pay_type','支付宝','ALIPAY',2,1),
  (11,'pay_type','储值余额','BALANCE',3,1),
  (24,'pay_type','对公转账','CASH',4,1),
  -- 支付状态
  (25,'pay_status','未支付','UNPAID',1,1),
  (26,'pay_status','已支付','PAID',2,1),
  (27,'pay_status','退款中','REFUNDING',3,1),
  (28,'pay_status','已退款','REFUNDED',4,1),
  (29,'pay_status','部分退款','PARTIAL_REFUNDED',5,1),
  -- 支付流水状态（t_payment.pay_status：UNPAID/SUCCESS/FAIL/REFUND，与订单支付状态取值不同）
  (95,'payment_status','未支付','UNPAID',1,1),
  (96,'payment_status','支付成功','SUCCESS',2,1),
  (97,'payment_status','支付失败','FAIL',3,1),
  (98,'payment_status','已退款','REFUND',4,1),
  -- 业务模式 / 销售模式 / 订单来源
  (30,'biz_mode','自营零售','RETAIL',1,1),
  (31,'biz_mode','渠道批发','WHOLESALE',2,1),
  (32,'sell_mode','仅自营','RETAIL',1,1),
  (33,'sell_mode','仅批发','WHOLESALE',2,1),
  (34,'sell_mode','自营+批发','BOTH',3,1),
  (35,'order_source','小程序','MINIAPP',1,1),
  (36,'order_source','H5 商城','H5',2,1),
  (37,'order_source','PC 官网','PC',3,1),
  (38,'order_source','后台代客下单','ADMIN',4,1),
  (39,'order_source','渠道商端','CHANNEL',5,1),
  -- 湖蟹公母
  (12,'crab_sex','公蟹','MALE',1,1),
  (13,'crab_sex','母蟹','FEMALE',2,1),
  (14,'crab_sex','公母混装','MIXED',3,1),
  -- 冷链发货状态
  (15,'ship_status','待发货','WAIT',1,1),
  (16,'ship_status','分拣中','SORTING',2,1),
  (17,'ship_status','已打包','PACKED',3,1),
  (18,'ship_status','已出库','OUTBOUND',4,1),
  (19,'ship_status','已发货','SHIPPED',5,1),
  (20,'ship_status','运输中','IN_TRANSIT',6,1),
  (21,'ship_status','已签收','SIGNED',7,1),
  -- 渠道等级 / 渠道状态
  (40,'channel_level','一级渠道','L1',1,1),
  (41,'channel_level','二级渠道','L2',2,1),
  (42,'channel_level','三级渠道','L3',3,1),
  (43,'channel_status','待审核','PENDING',1,1),
  (44,'channel_status','正常','NORMAL',2,1),
  (45,'channel_status','已驳回','REJECTED',3,1),
  (46,'channel_status','已冻结','FROZEN',4,1),
  -- 会员等级 / 性别
  (47,'member_level','普通会员','NORMAL',1,1),
  (48,'member_level','银卡会员','SILVER',2,1),
  (49,'member_level','金卡会员','GOLD',3,1),
  (50,'member_level','黑卡会员','BLACK',4,1),
  (51,'gender','未知','0',1,1),
  (52,'gender','男','1',2,1),
  (53,'gender','女','2',3,1),
  -- 审核状态（报单审核 / 渠道申请）
  (54,'audit_status','待审核','PENDING',1,1),
  (55,'audit_status','已通过','APPROVED',2,1),
  (56,'audit_status','已驳回','REJECTED',3,1),
  -- 佣金结算状态 / 结算单状态
  (57,'settle_status','待结算','PENDING',1,1),
  (58,'settle_status','已结算','SETTLED',2,1),
  (59,'settle_status','已作废','CANCELLED',3,1),
  (60,'settlement_status','草稿','DRAFT',1,1),
  (61,'settlement_status','已确认','CONFIRMED',2,1),
  (62,'settlement_status','已打款','PAID',3,1),
  -- 佣金类型
  (63,'commission_type','分销佣金','SALE',1,1),
  (64,'commission_type','转介绍返佣','REFERRAL',2,1),
  (65,'commission_type','团队级差','TEAM',3,1),
  -- 变动类型（积分 / 储值 / 授信额度共用）
  (66,'change_type','增加','EARN',1,1),
  (67,'change_type','消费','CONSUME',2,1),
  (68,'change_type','退回','REFUND',3,1),
  (69,'change_type','后台调整','ADMIN',4,1),
  (70,'change_type','提额','INCREASE',5,1),
  (71,'change_type','占用','OCCUPY',6,1),
  (72,'change_type','释放','RELEASE',7,1),
  -- 卡券类型 / 文章状态
  (73,'coupon_type','满减券','CASH',1,1),
  (74,'coupon_type','折扣券','DISCOUNT',2,1),
  (91,'coupon_type','赠品券','GIFT',3,1),
  (75,'article_status','草稿','DRAFT',1,1),
  (76,'article_status','已发布','PUBLISHED',2,1),
  (77,'article_status','已下线','OFFLINE',3,1),
  -- 通用状态 / 是否（tinyint 用字符串存字典值，前端按字符串比较）
  (78,'status','启用','1',1,1),
  (79,'status','停用','0',2,1),
  (80,'yes_no','是','1',1,1),
  (81,'yes_no','否','0',2,1),
  -- 平台 / 菜单类型 / 链接类型（菜单维护页）
  (82,'platform','后台菜单','ADMIN',1,1),
  (83,'platform','PC 官网导航','PC',2,1),
  (84,'platform','公众号菜单','WECHAT_MP',3,1),
  (85,'platform','小程序 tabBar','MINIAPP',4,1),
  (92,'platform','H5 底部导航','H5',5,1),
  (93,'platform','渠道商端','CHANNEL',6,1),
  (86,'menu_type','目录','DIR',1,1),
  (87,'menu_type','菜单','MENU',2,1),
  (88,'menu_type','按钮','BUTTON',3,1),
  (89,'link_type','站内路由','INNER',1,1),
  (90,'link_type','外部链接','OUTER',2,1),
  (94,'link_type','小程序页面','MINIAPP',3,1)
ON DUPLICATE KEY UPDATE
  `dict_type`=VALUES(`dict_type`),
  `item_label`=VALUES(`item_label`),
  `item_value`=VALUES(`item_value`),
  `sort`=VALUES(`sort`),
  `status`=VALUES(`status`);

-- 敏感词基础词库
INSERT IGNORE INTO `sys_sensitive_word` (`word`,`level`) VALUES ('测试敏感词',1),('违规',2);

-- 对象存储：5 驱动预置（未选中的驱动不启用）
INSERT INTO `sys_storage_config` (`driver`,`config_json`,`is_active`,`test_passed`) VALUES
  ('LOCAL','{"basePath":"/data/upload","domain":"https://xiegongzhu.com/files"}',0,0),
  ('S3','{"endpoint":"","region":"","bucket":"","accessKey":"","secretKey":"","domain":""}',0,0),
  ('OSS','{"endpoint":"","bucket":"","accessKeyId":"","accessKeySecret":"","domain":""}',0,0),
  ('COS','{"region":"","bucket":"","secretId":"","secretKey":"","domain":""}',0,0),
  ('MINIO','{"endpoint":"http://minio:9000","bucket":"xiegongzhu","accessKey":"minioadmin","secretKey":"minioadmin","domain":""}',1,1)
ON DUPLICATE KEY UPDATE `config_json`=VALUES(`config_json`);

-- CMS 栏目（对应 PC 官网落地页）
INSERT INTO `cms_category` (`category_name`,`category_name_en`,`category_code`,`sort`) VALUES
  ('品牌故事','Brand Story','brand',1),
  ('养殖基地','Farming Base','base',2),
  ('捕捞实景','Harvest Scene','catch',3),
  ('招商合作','Partnership','recruit',4),
  ('平台公告','Notice','notice',5)
ON DUPLICATE KEY UPDATE `category_name`=VALUES(`category_name`);
