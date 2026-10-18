# 螃蟹小公主 · 鄱阳湖湖蟹 多端数字化平台

> 域名 xiegongzhu.com ｜ 自营直销（C 端）+ 分销批发（B 端）双模式
> 依据 `PRO.md`（PRD）、`tasks.md`（T01-T31）、`checklist.md`（验收清单）生成。

## 一、目录结构

```
xiegongzhu.com
├── poyang-crab-backend/     Spring Boot 3 + MyBatis-Plus 后端（多端同源 API）
├── poyang-crab-admin/       PC 统一后台（Vue3 + Vite + TS + Element Plus）
├── poyang-crab-h5/          H5 分享页 / 活动落地页（Vue3 + Vite）
├── poyang-crab-miniapp/     C 端自营小程序（微信原生）
├── poyang-crab-channel/     渠道商端小程序（B 端，微信原生）
├── sql/                     建库建表 + 初始化数据 + 全量备份脚本
├── scripts/                 原生（非 Docker）启停脚本：自检 / 初始化 / 一键启动 / 停止
├── deploy/                  Docker Compose 一键编排 + Nginx 配置
└── docs/                    架构说明 / 接口约定 / 对接清单
```

冷链发货端（业务一线端）以 `poyang-crab-admin` 内独立路由模块 `ship` 承载（仓管/发货员角色）。

## 二、技术栈（PRO.md 第三章）

| 层 | 选型 |
|---|---|
| 后端 | Java 17 + Spring Boot 3 + MyBatis-Plus |
| 数据库 | MySQL 8（utf8mb4，HikariCP，读写分离开关） |
| 中间件 | Redis、RabbitMQ |
| 后台 | Vue3 + Vite + TypeScript + Element Plus（vue-pure-admin 风格） |
| 小程序 | 微信原生小程序（C 端 + 渠道商端各一套） |
| 对象存储 | 本地 / S3 / 阿里云 OSS / 腾讯云 COS / MinIO（5 驱动可切） |
| 部署 | Docker Compose |

> 未选 Elasticsearch / Kafka，未生成独立 App（Flutter）。

## 三、本地启动

> **开发模式（不使用 Docker）**：本机自备 MySQL 8 / Redis / RabbitMQ 即可跑通全链路；
> MinIO 可选，未部署时把对象存储驱动切到 `LOCAL`（见 3.4）。

### 3.1 依赖服务（二选一）

**A. 本机中间件（开发模式）**

| 组件 | 默认端口 | 默认账号 / 配置 |
| --- | --- | --- |
| MySQL 8 | 3306 | 库 `poyang_crab`，账号 `poyang_crab / BZcEXmWxiDcmx5bw` |
| Redis | 6379 | 无密码（可用环境变量 `REDIS_PASSWORD` 覆盖） |
| RabbitMQ | 5672 / 15672 | 用户 `poyang_crab`、vhost `/poyang_crab` |
| MinIO | 9000 | **可选**，未部署时见 3.4 切换到 `LOCAL` |

**B. Docker Compose**：见「四、Docker 一键部署」。

### 3.2 初始化数据库

**方式一：脚本（推荐，幂等，Windows）**

```bat
scripts\init-db.bat
:: 库 / 账号尚未创建时，先用 root 建：
:: powershell -File scripts\init-db.ps1 -RootUser root -RootPassword <你的root密码>
```

**灌入演示数据（可选，本地/演示环境）**：让商品、库存、会员、卡券、订单、支付、评价、发货单、
渠道档案、报单审核、佣金规则、对账结算、文章、渠道申请等列表页都有数据，便于逐项验收：

```bat
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\init-db.ps1 -Force -WithDemo
:: 或直接执行： mysql -upoyang_crab -p poyang_crab < sql/98_demo_data.sql
```

> `sql/98_demo_data.sql` 全部为固定主键 + `INSERT IGNORE`，可重复执行；**生产环境不要执行**。

**方式二：手工执行 SQL**

```bash
mysql -uroot -p < sql/00_create_database.sql
mysql -uroot -p poyang_crab < sql/01_system.sql
mysql -uroot -p poyang_crab < sql/02_member_product.sql
mysql -uroot -p poyang_crab < sql/03_order.sql
mysql -uroot -p poyang_crab < sql/04_channel.sql
mysql -uroot -p poyang_crab < sql/05_cms.sql
mysql -uroot -p poyang_crab < sql/99_init_data.sql
mysql -uroot -p poyang_crab < sql/98_demo_data.sql   # 可选：演示数据
```

执行后共 **43 张表**；初始账号 `admin / Admin@123456`（**上线前必须修改**）。

### 3.3 一键启动脚本（推荐）

Windows 原生启停脚本（**不使用 Docker**），详见 [`scripts/README.md`](scripts/README.md)：

```bat
scripts\check-env.bat     :: 环境自检：运行时 / 中间件端口 / 客户端 / 目录 / SQL / 应用端口
scripts\init-db.bat       :: 初始化数据库（幂等，已有表自动跳过）
scripts\start-all.bat     :: 一键启动：依赖检查 → 数据库 → 后端 → 对象存储 → 后台 → H5
scripts\preview-miniapp.bat :: 可选：小程序浏览器预览（本机没装微信开发者工具时看两套小程序的效果，:8850）
scripts\stop-all.bat      :: 停止全部服务（按窗口 PID，再按端口兜底；含 :8850）
```

脚本行为要点：

- 每个服务在**独立 PowerShell 窗口**运行，关掉窗口即停止该服务，窗口内可看实时日志；
- 后端启动后轮询 `/api/actuator/health`，通过才继续；
- 本机未部署 MinIO 时，**自动通过后端接口**把对象存储驱动切到 `LOCAL`（同时落库 + 写 Redis）；
- 中间件地址/账号可用环境变量覆盖（`CRAB_DB_HOST`、`CRAB_DB_PASSWORD` 等）。

### 3.4 手动启动（逐个启动）

```bash
# 后端（dev，端口 8080，context-path /api）
cd poyang-crab-backend && mvn spring-boot:run

# 后台（端口 8848，/api 已由 vite 代理到 8080）
cd poyang-crab-admin && npm i && npm run dev

# H5 / PC 官网（端口 8849）
cd poyang-crab-h5 && npm i && npm run dev

# 小程序：微信开发者工具分别导入 poyang-crab-miniapp / poyang-crab-channel
# （导入步骤见两个小程序各自的 README「本地运行」章节）

# 小程序浏览器预览（本机未装微信开发者工具时，按真实 WXML/WXSS 看效果，端口 8850）
scripts\preview-miniapp.bat
```

冒烟自检：`GET http://localhost:8080/api/actuator/health` 应返回 `{"status":"UP"}`。

### 3.5 无 MinIO 时切换为本地存储

初始化数据默认激活 `MINIO`。本机未部署 MinIO 时，`scripts\start-all.bat` 会自动完成切换；
也可在后台「系统管理 → 对象存储」先「测试连接」再「保存并应用」`LOCAL` 驱动（本地磁盘 `./data/upload`）。

> ⚠️ 不要用 `redis-cli set storage:active:driver LOCAL` 手写 Redis：后端对该键使用 JSON 序列化，
> 实际存储值是带引号的 `"LOCAL"`，裸写会导致驱动读取异常；请通过后台页面或后端接口切换。

## 四、Docker 一键部署

```bash
cd deploy
cp .env.example .env        # 按需修改密码
docker compose up -d
docker compose ps
```

## 五、脚手架落地清单（对应 tasks.md）

| 任务 | 落地位置 |
|---|---|
| T01/T02 | `poyang-crab-backend/pom.xml`、`BaseEntity`、`sql/00_create_database.sql` |
| T03 | `sql/01~05_*.sql`（全量表结构） |
| T04 | `application-dev.yml`（HikariCP）、`deploy/backup/` |
| T05 | `config/RedisConfig.java`、`common/redis/` |
| T06 | `config/RabbitMQConfig.java`、`mq/`（含延迟队列） |
| T07/T08 | `poyang-crab-admin/src/views/system/**`（含**字典管理**：全站枚举/状态统一维护并中文显示） |
| T09 | `sys_lang` / `sys_i18n`、`admin/src/locales` |
| T10 | `admin/src/views/system/menu/**`（菜单树 + 拖拽 + 预览） |
| T11 | `admin/src/components/RichEditor` |
| T12 | `admin/src/views/system/storage/**`（5 驱动卡片） |
| T13 | `admin/src/components/ImageUpload`（独占整行） |
| T13.1 | `admin/src/components/ScanInput`（扫码录入：摄像头条形码 + 扫码枪），用于订单号 / 顺丰运单号 |
| T14 | `common/aspect/AuditLogAspect.java`、`sys_audit_log` |
| T15/T16 | `poyang-crab-h5/`、`admin/portal` |
| T17 | `module/wechat/`（服务号、模板消息、菜单） |
| T18-T22 | `poyang-crab-miniapp/` |
| T23 | `poyang-crab-h5/` |
| T24 | `admin/src/views/ship/**` |
| T25-T28 | `poyang-crab-channel/`、`module/channel/` |
| T29-T31 | `docs/`、`deploy/`（Nginx HTTPS、备份演练） |

未实现处均以 `TODO(Txx)` 标注，便于按清单继续推进。

## 六、文档

| 文档 | 说明 |
| --- | --- |
| [docs/architecture.md](./docs/architecture.md) | 系统架构、模块划分、下单/报单关键链路、部署拓扑 |
| [docs/api-convention.md](./docs/api-convention.md) | 接口统一约定、鉴权白名单、错误码、CRUD 规范、安全与审计约定 |
| [docs/go-live-checklist.md](./docs/go-live-checklist.md) | 上线资质、微信/支付/顺丰对接、合规与验收清单（T30/T31） |
| [docs/todo-index.md](./docs/todo-index.md) | 全仓库 `TODO(Txx)` 索引 |
| [scripts/miniapp-preview/README.md](./scripts/miniapp-preview/README.md) | 小程序浏览器预览：原理、能力清单、已知边界、常见问题 |

各子工程另有独立 README：`poyang-crab-backend`、`poyang-crab-admin`、`poyang-crab-h5`、`poyang-crab-miniapp`、`poyang-crab-channel`。
