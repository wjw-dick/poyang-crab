# poyang-crab-channel · 渠道商端微信原生小程序

螃蟹小公主 · 鄱阳湖湖蟹 **渠道商 / 经销商 / 代理** 专用小程序（微信原生），负责报单、渠道专属价、佣金与转介绍返佣、额度、对账结算。

## 目录结构

```
poyang-crab-channel/
├── app.js / app.json / app.wxss      # 入口：渠道商登录态、站点参数、报单草稿缓存
├── project.config.json               # 微信开发者工具工程配置（appid 需替换）
├── sitemap.json                      # 渠道端禁止被微信索引（business 内部使用）
├── config/index.js                   # 环境配置（dev / test / prod）
├── utils/
│   ├── request.js                    # 统一请求封装（token key = CHANNEL_TOKEN）
│   ├── auth.js                       # 微信登录 + 渠道档案绑定校验
│   └── format.js                     # 金额/日期/各业务状态字典
├── api/index.js                      # 接口层（/channel/biz/**）
└── pages/
    ├── index/index                   # 工作台：额度 / 待结算佣金 / 快捷入口
    ├── product/index                 # 渠道专属价（SKU 批发价 + 加入报单）
    ├── report/index                  # 报单（草稿 → 提交 → 我的报单）
    ├── mine/index                    # 我的：档案 / 入口 / 退出
    ├── order/index                   # 批发订单（含明细展开）
    ├── commission/index              # 佣金 / 转介绍返佣明细
    ├── settlement/index              # 对账结算（生成/确认）+ 额度流水
    ├── dealer/index                  # 下级经销商团队
    └── login/index                   # 微信登录 + 渠道档案校验
```

## 与后端的接口对应（`ChannelBizController`，前缀 `/channel/biz`）

| 能力 | 接口 | 说明 |
| --- | --- | --- |
| 微信登录 | `POST /wx/login?code=&source=CHANNEL` | `WxAuthController`，按 UnionID 识别 |
| 渠道档案 | `GET /channel/biz/profile` | 从登录态解析 channelId，脱敏 unionId / 证照 |
| 工作台概览 | `GET /channel/biz/overview` | 额度、待结算佣金、下级数、起订量与默认比例 |
| 额度流水 | `GET /channel/biz/quota/logs` | 额度变动明细 |
| 渠道专属价 | `GET /channel/biz/product/list` | 仅 WHOLESALE / BOTH 在架商品，含 SKU 批发价 |
| 报单提交 | `POST /channel/biz/report/submit` | body 为 `[{skuId, qty}]`，起订量由系统参数控制 |
| 我的报单 | `GET /channel/biz/report/page` | 审核状态：PENDING / APPROVED / REJECTED |
| 佣金 | `GET /channel/biz/commission/page` | 类型：DISTRIBUTION 销售分佣 / REFERRAL 转介绍返佣 |
| 结算单 | `GET /channel/biz/settlement/page`、`GET /channel/biz/settlement/create`、`POST /channel/biz/settlement/{settleNo}/confirm` | 按周期生成 → 确认 → 待打款 |
| 下级经销商 | `GET /channel/biz/dealer/list` | 按 `parent_id` 反查 |
| 批发订单 | `GET /trade/order/page`、`/trade/order-item/page` | 报单审核通过后生成的正式订单 |

> **安全约定**：渠道端所有接口的 `channelId` 都由后端从登录态解析（`CurrentUserHolder.channelId()`），前端不传也不应传，避免越权查看他人数据。

## 本地运行

1. 微信开发者工具「导入项目」，选择本目录，替换 `project.config.json` 中的 AppID。
2. `config/index.js` 的 `ENV = 'dev'`，勾选「不校验合法域名」。
3. 前置数据：后台「渠道商管理」中维护渠道商档案，并填入渠道商的 `union_id`；否则登录会提示未绑定渠道档案。

## 已知待办（TODO）

| 标记 | 说明 |
| --- | --- |
| `TODO(T25)` | 渠道商账号的开通/停用仍由后台「渠道商管理」维护（需填入渠道商微信 UnionID），自助注册流程未开放 |
| `TODO(T27)` | 邀请下级经销商（邀请码 / 小程序码）未实现 |
| `TODO(T27)` | 工作台汇总口径：待结算佣金为实时聚合，正式上线建议加缓存 |
| `TODO(T28)` | 结算单打款流程（`payTime` / `PAID` 状态）待接入财务 |

## 登录链路说明（已实现）

`POST /wx/login?code=&source=CHANNEL` 已走独立链路（`ChannelAuthService`）：

1. `code2Session` 取 `openid` / `unionid`；
2. 按 `t_channel.union_id` 匹配渠道档案，未匹配到直接报「未绑定渠道商档案」；
3. 匹配成功则签发 `roleType=CHANNEL`、`loginType=CHANNEL`、`channelId=t_channel.id` 的 JWT。

因此渠道端所有 `/channel/biz/**` 接口都能从登录态拿到 `channelId` 做归属过滤，前端无需（也不应）传 `channelId`。

**前置数据**：后台「渠道商管理」中创建渠道商，并把该微信号的 UnionID 写入 `t_channel.union_id`；否则登录会被拒绝。

## 生产注意

- `sitemap.json` 已禁止微信索引渠道端页面。
- 需在微信公众平台单独申请渠道端小程序（或复用同一小程序的渠道入口），并配置 request 合法域名。
- `tabBar` 未配置图标（避免提交二进制占位），正式发布前补充 `iconPath` / `selectedIconPath`。
