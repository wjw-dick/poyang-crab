# 系统架构说明

## 一、总体拓扑

```
                      ┌──────────────────────────────┐
   微信小程序(C端) ───►│                              │
   渠道商小程序(B端) ─►│   Nginx (HTTPS / 静态托管)    │
   H5 / PC 官网     ─►│   admin. / h5. / static. /   │
   统一后台(admin)  ─►│   api.xiegongzhu.com         │
                      └──────────────┬───────────────┘
                                     │ /api 反向代理
                      ┌──────────────▼───────────────┐
                      │  poyang-crab-backend         │
                      │  Spring Boot 3 / Java 17     │
                      │  context-path = /api         │
                      └──┬───────┬────────┬──────────┘
                         │       │        │
              ┌──────────▼─┐ ┌───▼────┐ ┌─▼──────────┐
              │  MySQL 8   │ │ Redis  │ │ RabbitMQ   │
              │  业务主库   │ │ 缓存/限流│ │ 延迟队列/MQ │
              └────────────┘ └────────┘ └────────────┘
                         │
              ┌──────────▼──────────────────────────┐
              │ 对象存储：本地 / S3 / OSS / COS / MinIO │
              │ （StorageFactory 按 sys_storage_config 切换）│
              └─────────────────────────────────────┘
```

## 二、后端模块划分（`com.xiegongzhu.crab`）

| 包 | 职责 |
| --- | --- |
| `common` | 统一响应 `R`/`PageResult`、`BaseEntity`、异常、AOP（限流 `RateLimitAspect` / 审计 `AuditLogAspect`）、鉴权（`JwtUtils`、`AuthInterceptor`）、存储抽象（`StorageFactory` + 5 驱动）、`BaseCrudController` 泛型 CRUD 基类 |
| `module.system` | 用户 / 角色 / 菜单 / 字典 / 多语言 / 系统参数 / 对象存储配置 / 文件 / 审计日志 / 敏感词 |
| `module.product` | 商品 / 分类 / 湖蟹规格（公母·重量档·礼盒）/ SKU / 库存 / 库存流水 / 购物车 / 直播间 |
| `module.trade` | 订单 / 明细 / 支付 / 冷链物流 / 评价 |
| `module.member` | 会员（UnionID 互通）/ 地址 / 积分 / 储值 / 卡券 |
| `module.channel` | 渠道商 / 渠道订单（报单）/ 佣金 / 结算 / 额度流水 / 上下级关系 |
| `module.cms` | 文章 / 分类 / 招商申请 |
| `module.wechat` | 小程序登录、公众号菜单与模板消息、微信支付、支付回调 |
| `module.logistics` | 顺丰冷链：面单、轨迹 |
| `module.portal` | PC/H5/小程序共用的公开数据源（免登录 `/portal/**`） |
| `mq` | 订单超时取消（延迟队列）、支付回调、评价等消息生产者与消费者 |

## 三、关键链路

### 1. 下单 → 支付 → 发货 → 收货

```
POST /order/create
  ├─ 校验 SKU / 起订量 / 渠道价（批发）
  ├─ 锁定库存（stock.locked_qty，乐观锁 version）
  └─ 投递延迟消息（crab.order.delay.exchange，TTL=超时分钟）
        └─ 超时未支付 → 死信 → crab.order.cancel.queue → 释放锁定库存 + 订单置 CANCELLED

POST /order/pay        → 创建支付流水 → 返回 wx.requestPayment 参数
POST /pay/notify/wechat→ 验签 → markPaid → 订单 PAID（同时触发佣金计算）
POST /order/ship       → 回填运单号 + 打包核验 → 扣减库存（锁定转出库）→ SHIPPED
POST /order/confirm    → RECEIVED（触发评价入口）
```

订单状态字典：`UNPAID / PAID / SORTING / PACKED / SHIPPED / RECEIVED / COMPLETED / CANCELLED / REFUNDING / REFUNDED`。

### 2. 渠道商报单 → 审核 → 批发订单 → 佣金 → 结算

```
POST /channel/biz/report/submit  → 按渠道专属价计价，校验起订量 → 报单 PENDING
POST /channel/biz/report/audit   → 后台审核通过 → 复用订单体系生成 WHOLESALE 订单
POST /channel/biz/commission/calculate → 分佣 + 上级转介绍返佣（比例快照留痕）
GET  /channel/biz/settlement/create    → 按周期汇总待结算佣金生成结算单 DRAFT
POST /channel/biz/settlement/{no}/confirm → CONFIRMED，佣金置 SETTLED
```

### 3. 金额与比例配置化（PRO.md 6.2 红线）

所有金额、比例、阈值一律走 `sys_config`，例如：

| 配置键 | 含义 | 默认值 |
| --- | --- | --- |
| `business.freight.cold.chain` | 冷链运费 | 见 `99_init_data.sql` |
| `business.order.expire.minutes` | 未支付超时（分钟） | 30 |
| `business.channel.min.order.qty` | 批发起订量 | 10 |
| `business.channel.default.commission.rate` | 默认分佣比例(%) | — |
| `business.channel.default.referral.rate` | 默认转介绍返佣比例(%) | — |

密钥类（微信 AppSecret、支付密钥、存储 AK/SK）**加密存储**（`CryptoConfig` + `AesUtils`），`/portal/site` 与渠道端档案接口一律不下发。

## 四、部署（`deploy/docker-compose.yml`）

服务清单：`mysql8` / `redis` / `rabbitmq` / `minio` / `minio-init` / `app-backend` / `app-admin` / `app-h5` / `app-static` / `mysql-backup` / `nginx`。

- `sql/*.sql` 通过 `docker-entrypoint-initdb.d` 挂载，首次启动自动建库建表与初始化。
- `nginx/conf.d/` 分别承载 `admin` / `h5` / `static`（小程序产物） / 主站。
- `backup/backup-mysql.sh` 定时逻辑备份（见 T04）。
