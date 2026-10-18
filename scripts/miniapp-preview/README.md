# 小程序浏览器预览（本机无微信开发者工具时的等效方案）

用**浏览器**按**真实的 WXML / WXSS / JS** 渲染 `poyang-crab-miniapp`（C 端）与 `poyang-crab-channel`（渠道商端），
用于本机快速看效果、核对页面与接口联调；**不替代**微信开发者工具的 `wx.*` 真机能力（支付、扫码、真机调试）。

## 一、启动

```bat
:: 前置：后端已启动（scripts\start-backend.bat 或 start-all.bat）
scripts\preview-miniapp.bat
:: 指定端口 / 不自动打开浏览器
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\preview-miniapp.ps1 -Port 8851 -NoOpen
```

| 入口 | 地址 | 说明 |
| --- | --- | --- |
| 双端并排 | http://localhost:8850/preview/ | 左 C 端、右渠道商端（`#miniapp` / `#channel` 可直达单个） |
| 单端大屏 | http://localhost:8850/preview/single.html?app=channel | 单台手机独立窗口，便于演示/截图 |
| 停止 | `scripts\stop-all.bat` | 端口 `8850` 已纳入统一停止 |

也可以在 `scripts\start-all.ps1` 之外单独跑：

```bash
node scripts/miniapp-preview/server.mjs --port 8850 --backend http://localhost:8080 --open
```

## 二、它做了什么

| 能力 | 实现说明 |
| --- | --- |
| 模块系统 | 同步 XHR 拉源码 + CommonJS `require`（相对/绝对路径），真实执行 `App()` / `Page()` / `getApp()` / `getCurrentPages()` |
| 数据驱动 | `setData(patch, cb)` 支持 `a.b` / `a[0]` 路径写法，改数据即重渲染 |
| WXML 模板 | `{{}}` 插值（含 `a && b`、三元、`+` 拼接、`||` 默认值）、`wx:if / wx:elif / wx:else`、`wx:for`（`wx:for-item` / `wx:for-index` / `wx:key`）、`block`、`hidden` |
| 事件 | `bindtap` / `catchtap` / `bindinput` / `bindconfirm` / `bindchange` / `bindgetphonenumber`，按 `data-*` 还原 `e.currentTarget.dataset` |
| 样式 | WXSS 原样注入 Shadow DOM；`rpx → px`（375 视口，`1rpx = 0.5px`）；`page` 选择器映射到 `:host`；`image` 渲染为 `img` |
| 请求 | `wx.request` 把 `http://localhost:8080/api`（各端 `config/index.js` 的 `BASE_URL`）改写为**同源** `/api`，由 Node 反代到后端，天然避开 CORS 与「不校验合法域名」 |
| wx API | `request` / `uploadFile` / `login` / `chooseMedia` / `previewImage` / `requestPayment` / `showToast` / `showLoading` / `hideLoading` / `showModal` / `setClipboardData` / `makePhoneCall` / `navigateTo` / `switchTab` / `redirectTo` / `reLaunch` / `navigateBack` / `stopPullDownRefresh` / `get|set|removeStorageSync` |
| 外壳 | 手机壳 + 导航栏标题（取自页面 `.json`）+ `tabBar`（`app.json` 驱动）+ 返回栈 + 页面胶囊（快速跳页）+ **请求日志**（方法/URL/业务码/耗时）+ 登录态下拉 |

## 三、登录态怎么来的

`/wx/login` 走微信 `code2Session`，本机 `wechat.mini.*` 为空必然失败，所以预览用**后端同一 JWT 密钥**
（`crab.jwt.secret`，可用 `CRAB_JWT_SECRET` 覆盖）在本地签发**预览令牌**（HS256，claims：`sub/username/loginType/roleType/channelId/iat/exp`，有效期 24h），
再用 `GET /preview/token?app=&id=` 下发到页面，写入两个小程序各自的 storage key：

| 端 | 令牌 key | 用户 key | 可选登录态 |
| --- | --- | --- | --- |
| C 端 | `CRAB_TOKEN` | `CRAB_USER` | 未登录 / 会员 1（鄱阳湖畔的吃货 · GOLD）/ 会员 2 / 会员 3 |
| 渠道商端 | `CHANNEL_TOKEN` | `CHANNEL_INFO` | 未登录 / 渠道 1（南昌蟹逅商贸有限公司）/ 渠道 2（九江鲜生优选） |

`AuthInterceptor` 只校验签名不查库，所以令牌能直接通过鉴权、拿到演示数据（会员/渠道/订单/佣金等）。

> ⚠️ 预览令牌只在 `127.0.0.1` 本机使用；生产环境**绝不要**暴露 `/preview/token`。

## 四、边界（这里的「不支持」是刻意为之）

- 不执行真机能力：`wx.requestPayment`（真支付）、`wx.scanCode`（真扫码）、`chooseMedia` 的真实相册、订阅消息、真机调试；
  需要这些请用微信开发者工具 + 真机预览。
- 不支持自定义组件（`Component()` 当前返回 `null`）、`wx.createSelectorQuery`、`IntersectionObserver`、`canvas`、`map`、直播组件。
- `document.hidden` 恒为 `true`（窗口不在前台），因此**不要依赖 `requestAnimationFrame` 或过渡动画**推进逻辑。
- 不同版本的 `image` 的 `mode`（`aspectFill` 等）只做了近似；预览里用内联 SVG 占位图替代演示数据里的空图。
- 详情类页面在预览里由「页面胶囊」自动带上演示参数（`defaultQuery`），真实小程序由上一页跳转时携带。

## 五、文件结构

| 文件 | 作用 |
| --- | --- |
| `server.mjs` | 静态服务（仓库根 + `/preview/*`）+ `/api/**` 反代 8080 + `/preview/token` 签发预览令牌；参数 `--port` / `--backend` / `--open` |
| `runtime.js` | 浏览器 mini-runtime：模块系统、模板编译与渲染、事件、`setData`、wx API shim、路由栈 |
| `ui.js` | 双端设备外壳：登录态注入、页面胶囊、请求日志、tabBar、返回栈（`APPS` 配置在文件顶部） |
| `index.html` | 双端预览页（`#miniapp` / `#channel`） |
| `single.html` | 单端预览页（`?app=miniapp|channel`） |
| `style.css` | 预览外壳样式（手机壳 / 日志 / 工具栏） |

## 六、常见问题

| 现象 | 处理 |
| --- | --- |
| 页面空白、日志报 `require 路径非法` | 相对路径依赖 `location.origin` 兜底，源码已处理；若自行改动 `loadModule` 请勿把 base 写成相对路径 |
| 页面重进后报 `页面未注册（Page() 未执行）` | 页面模块被缓存后不会再执行 `Page()`，已用 `pageOptionsCache` 兜底；新增「跳过模块缓存」逻辑时须同步该缓存 |
| 所有 `wx:if` / `wx:for` 都失效 | 指令属性的值本身带 `{{ }}`，求值前必须剥壳（`evalExpr` 已统一处理） |
| 接口 502 / 请求日志红字 | 后端未启动：先 `scripts\start-backend.bat`（预览健康状态在启动日志里会提示） |
| 需要看真实微信环境 | 用微信开发者工具导入两个小程序目录，见 `poyang-crab-miniapp/README.md`、`poyang-crab-channel/README.md` |
