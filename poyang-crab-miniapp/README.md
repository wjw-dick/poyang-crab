# poyang-crab-miniapp · C 端微信原生小程序

螃蟹小公主 · 鄱阳湖湖蟹 C 端商城（微信原生小程序，非 uni-app / Taro）。

## 目录结构

```
poyang-crab-miniapp/
├── app.js / app.json / app.wxss      # 入口：全局登录态、站点参数、购物车缓存、主题变量
├── project.config.json               # 微信开发者工具工程配置（appid 需替换）
├── sitemap.json                      # 微信索引规则
├── config/index.js                   # 环境配置（dev / test / prod 三套 baseURL）
├── utils/
│   ├── request.js                    # 统一请求封装：JWT、{code,message,data}、401 跳登录
│   ├── auth.js                       # wx.login 换 JWT、手机号绑定
│   └── format.js                     # 金额/日期/订单状态/公母文案
├── api/index.js                      # 接口层（portal/auth/member/cart/order/review/live）
└── pages/
    ├── index/index                   # 商城首页：分类 + 商品列表 + 直播间入口 + 品牌内容
    ├── product/detail                # 商品详情：公母 / 重量档 / 包装 + SKU 价格 + 评价 + 富文本
    ├── cart/index                    # 购物车（tabBar）
    ├── order/confirm                 # 确认订单（地址 + 备注 + 下单 + 微信支付）
    ├── order/list                    # 订单列表（tabBar，状态筛选）
    ├── order/detail                  # 订单详情（商品 / 金额 / 运单 / 操作）
    ├── logistics/index               # 顺丰冷链物流轨迹（时间轴）
    ├── review/index                  # 发表评价（评分 + 存活率 + 图片上传）
    ├── member/index                  # 会员中心（积分 / 储值 / 卡券 / 地址管理）
    ├── login/index                   # 微信登录（UnionID 打通）
    └── article/index                 # 品牌故事等内容详情（rich-text）
```

## 与后端的接口对应

| 小程序能力 | 后端接口 | 后端位置 |
| --- | --- | --- |
| 站点参数 / 导航 / 多语言 | `GET /portal/{site,nav,i18n/{lang}}` | `PortalController` |
| 商品列表 / 详情 / 分类 | `GET /portal/product/list`、`GET /portal/product/{id}`、`GET /portal/category/list` | `PortalController` |
| CMS 文章 | `GET /portal/article/list`、`GET /portal/article/{id}` | `PortalController` |
| 微信登录 | `POST /wx/login?code=&source=` | `WxAuthController` |
| 购物车 | `/cart/**` | `CartController` |
| 下单 / 支付 / 收货 | `POST /order/{create,pay,confirm,cancel}` | `OrderBizController` |
| 订单查询 | `GET /trade/order/page`、`/trade/order-item/page`、`/trade/delivery/page` | `BaseCrudController` 派生 |
| 评价 | `POST /trade/review` | `ReviewController` |
| 物流轨迹 | `GET /logistics/track?expressNo=` | `SfExpressService#queryRoutes`（见待办） |
| 图片上传 | `POST /system/file/upload` | `SysFileController` |

## 本地运行

1. 用微信开发者工具「导入项目」，选择本目录，填入自己的 AppID（`project.config.json` 中 `wxPLACEHOLDER0000` 需替换）。
2. 本地联调：`config/index.js` 的 `ENV = 'dev'`，并在「详情 → 本地设置」勾选 **不校验合法域名**。
3. 启动后端（默认 `http://localhost:8080/api`，见 `poyang-crab-backend/README`）。

## 已知待办（TODO）

| 标记 | 说明 |
| --- | --- |
| `TODO(T18)` | `POST /wx/bind-phone` 未实现；`WxAuthController` 目前仅 `/wx/login` |
| `TODO(T21)` | 顺丰丰桥开放平台未接入，`/logistics/track` 返回骨架数据 |
| `TODO(T23)` | 直播间跳转、客服消息、埋点上报待接入 |
| `TODO(T24)` | `GET /trade/order/by-no/{orderNo}` 缺失，订单详情暂用分页筛选兜底；运费规则需从系统参数读取 |
| `TODO(T23)` | 购物车本地缓存与服务端合并策略待定（当前本地缓存兜底） |

## 生产注意

- `app.json` 的 `tabBar` 未配置 icon 图片（避免提交二进制占位）；正式发布前请补充 `iconPath` / `selectedIconPath`。
- 需在微信公众平台配置：业务域名、request 合法域名（`https://api.xiegongzhu.com`）、downloadFile/socket 域名。
- 小程序类目：需具备「生鲜食品」相关资质（见 `docs/` 上线资质清单）。
