# TODO(Txx) 索引

本仓库为**全量脚手架**：结构与分层齐备、可编译可启动，业务细节处统一以 `TODO(Txx)` 标注（`Txx` 对应 `tasks.md` 的任务号），便于按清单继续推进。

## 按任务归类

### T07 · 后台框架与 RBAC
| 位置 | 待办 |
| --- | --- |
| `poyang-crab-admin/src/layout/index.vue` | 用 **vue-pure-admin 官方 layout** 覆盖当前极简自建壳（PRO.md 6.1 红线要求） |
| `poyang-crab-admin/src/views/dashboard/index.vue` | 仪表盘统计接口对接（今日订单 / 销售额 / 待发货 / 复购率） |
| `SysMenuServiceImpl:30` | 按当前登录用户角色过滤菜单（`loadPerms` 已返回权限标识） |

### T12 · 对象存储 5 驱动
| 位置 | 待办 |
| --- | --- |
| `RemoteStorageService` | 接入 S3 / OSS / COS / MinIO 官方 SDK；连接测试需真实 `listBuckets` / `bucketExists` 校验 |

### T15 · H5 官网 SEO
| 位置 | 待办 |
| --- | --- |
| `poyang-crab-h5/vite.config.ts` | 双端 SEO：接入预渲染（`vite-plugin-prerender`）或 SSR 架构 |

### T17 · 公众号
| 位置 | 待办 |
| --- | --- |
| `LogisticsStatusConsumer` | 按 `shipStatus` 推送模板消息（已发货 / 派送中 / 已签收） |

### T18 · 小程序登录
| 位置 | 待办 |
| --- | --- |
| `poyang-crab-miniapp/utils/auth.js` | 后端未提供 `POST /wx/bind-phone`，需在 `MemberAuthService` 中实现 AppID 解密后放开 |
| `poyang-crab-miniapp/pages/login/index.js` | 手机号快捷绑定按钮当前为占位提示 |

### T20 · 微信支付
| 位置 | 待办 |
| --- | --- |
| `WxPayService` | 接入微信支付 APIv3：JSAPI 下单、回调验签 + AES-GCM 解密、退款 |

### T21 · 顺丰冷链
| 位置 | 待办 |
| --- | --- |
| `SfExpressService` | 接入丰桥开放平台：`EXP_RECE_CREATE_ORDER` 下单、`EXP_RECE_SEARCH_ROUTES` 轨迹查询 |
| `poyang-crab-miniapp/app.js` | 前端异常统一上报 |
| `admin/src/views/ship/outbound/index.vue` | 轨迹查询调 `GET /logistics/track?expressNo=` |

### T22 · 敏感词
| 位置 | 待办 |
| --- | --- |
| `ReviewController#submit` | 评价内容敏感词过滤需在 Service 层调用 `SensitiveWordService` |

### T23 · H5/小程序内容与运营
| 位置 | 待办 |
| --- | --- |
| `miniapp/pages/index/index.js` | 直播间跳转、订阅消息提醒、关联商品浮窗 |
| `miniapp/pages/product/detail.js` | 微信客服消息 / 后台客服系统接入 |
| `miniapp/pages/member/index.js` | 收货地址完整编辑弹层（省市区选择器） |
| `miniapp/pages/login/index.js` | 《用户协议》《隐私政策》静态页（可由 CMS 承载） |
| `miniapp/app.js` | 分享卡片 / 直播间 `scene` 参数解析与埋点 |
| `h5/src/views/Activity.vue` | 活动配置（主题、时间、商品组合）后台可配 |

### T24 · 发货端与交易收尾
| 位置 | 待办 |
| --- | --- |
| `miniapp/pages/cart/index.js` | 服务端 `cart` 表仅存 `memberId/skuId/qty/checked`，登录后需按 `skuId` 反查商品补齐展示字段并与本地合并 |
| `miniapp/pages/order/confirm.js` | 运费规则（满额包邮 / 偏远地区补差）需从 `sys_config` 读取，禁止写死 |
| `admin/src/views/ship/wait/index.vue` | 对接顺丰电子面单打印（`SfExpressService#printWaybill`） |

### T25 · 渠道商端登录与账号体系
| 位置 | 待办 |
| --- | --- |
| `channel/pages/login/index.js` | 「申请成为渠道商」跳转招商申请表（可复用 `POST /portal/channel-apply`） |

> 渠道商登录链路（`ChannelAuthService`）**已实现**：按 `t_channel.union_id` 匹配并签发 `roleType=CHANNEL` + `channelId` 的令牌。

### T27 · 渠道分销
| 位置 | 待办 |
| --- | --- |
| `channel/pages/dealer/index.js` | 邀请下级经销商（邀请码 / 小程序码），下级注册后自动挂靠 `parent_id` |
| `ChannelBizService#overview` | 待结算佣金为实时聚合，上线前建议加 Redis 缓存 |

### T28 · 结算
| 位置 | 待办 |
| --- | --- |
| `Settlement` 打款流程 | `payTime` / `PAID` 状态与财务打款对接 |

## 未被 TODO 标注但需注意的骨架实现

| 位置 | 说明 |
| --- | --- |
| `poyang-crab-admin/src/layout/index.vue` | 自建极简壳，非 vue-pure-admin 官方 layout（见上表 T07） |
| `RemoteStorageService` | 远程驱动为骨架，未引入重量级 SDK 依赖 |
| `WxMiniService#code2Session` | 真实调用微信接口；需先在系统参数配置 `wechat.mini.appid` / `wechat.mini.secret`，否则登录直接报错 |
| `SfExpressService#queryRoutes` | 返回骨架轨迹数据 |
| 小程序 `tabBar` | 未配置图标（避免提交二进制占位），发布前需补充 |
| 小程序 `project.config.json` | AppID 为占位符 `wxPLACEHOLDER0000` / `wxPLACEHOLDER1111` |
| `scripts/`（原生启停脚本） | Windows PowerShell 5.1+ 适配；一键启动/停止/自检/初始化数据库，不依赖 Docker。详见 `scripts/README.md` |
| `scripts/miniapp-preview/`（小程序浏览器预览） | 本机未装微信开发者工具时的等效预览：Node 静态服务 + `/api` 反代 `:8080` + 浏览器端 mini-runtime（真实执行 WXML/WXSS/JS）+ 本地签发**预览令牌**注入登录态。入口 `scripts\preview-miniapp.bat` → `http://localhost:8850/preview/`。详见 `scripts/miniapp-preview/README.md` |
| 后台侧边菜单来源 | 后端 `sys_menu` 与前端 `asyncRoutes`（`src/router/index.ts`）**一一对应**（7 分组 25 页面，`path`/`component`/`perm` 完全一致）。当前仍以静态路由 + `perm` 过滤渲染，`GET /system/menu/routes` 已备好但未接入；在后台新增菜单后需同步补前端路由文件 |
| 字典体系（`sys_dict` / `sys_dict_item`） | 全站枚举（状态 / 类型 / 等级 / 审核状态 / 支付状态 / 变动类型 …）**统一在「系统管理 → 字典管理」维护**，25 类 97 项。前端 `src/composables/useDict.ts` 登录后拉一次 `GET /system/dict/options` 做内存缓存；页面用 `Column.dict` / `Field.dict` 声明字典类型即可显示中文与渲染下拉 |
| 引用表名称显示（`src/composables/useLookup.ts`） | 分类 / 渠道 / 会员 / 商品 / SKU / 栏目 / 订单 / 角色等「存 id 的字段」一律用 `Column.lookup` / `Field.lookup`（+`lookupTop` 追加「顶级（0）」、`lookupEmpty` 兜底文案）显示名称与下拉，页面里不再出现裸 ID |
| 扫码录入（`src/components/ScanInput/index.vue`） | 输入框 + 「扫码」按钮；PC 端用 `html5-qrcode`（摄像头，支持 CODE_128 等条形码 + 二维码），**扫码枪走键盘输入路径**，同一输入框天然兼容。已用于「订单新增-订单号」「打包核验/出库发货-顺丰运单号」等所有运单号字段 |
| `BaseCrudController#page` 通用筛选 | 除 `current`/`size` 外，所有查询参数按「实体属性名 → 数据库列名」（`TableInfoHelper`）自动拼 WHERE：纯数字走等值、其它走模糊；并固定 `ORDER BY 主键`。各模块列表页的筛选因此开箱即用（订单号 / 分类 / 销售模式 / 状态…） |
| `sql/98_demo_data.sql` | **可选**演示数据（商品/库存/会员/卡券/积分储值/订单/支付/评价/发货单/渠道/报单/佣金/结算/文章/渠道申请）。默认不执行，本地验收用 `init-db.bat -Force -WithDemo`；生产环境不要执行 |

## 联调期已验证并修复的坑（勿回退）

| 位置 | 说明 |
| --- | --- |
| 后台 `<router-view>` 外层 `<transition mode="out-in">` | **绝对不要加回**。过渡动画靠 `requestAnimationFrame` 推进；标签页处于后台/窗口最小化时 rAF 被浏览器暂停，离开动画永远不结束，新路由就不会挂载 —— 表现就是「点菜单没反应 / 页面不切换」。已改为直接 `<component :is="Component" :key="route.path" />` |
| 刷新页面后的权限（`router/index.ts` 守卫 + `store/user.ts` + 后端 `AuthController#profile`） | JWT 只承载 userId/roleType，**不含 perms**。pinia 状态在刷新后重置（只有 token 从 localStorage 恢复），若直接 `registerRoutes` 会按空权限过滤掉**全部**动态路由 —— 表现就是「侧边菜单全空 / 点任何菜单都被兜底路由弹回看板」。三处缺一不可：① `AuthController#profile` 回查数据库补全 `perms`（`SysUserService#profile`）② 守卫在注册前 `await userStore.loadProfile()` ③ `login()` 里把 `routesLoaded` 置回 false |
| `src/api/request.ts` 响应拦截器 | 必须 `return body?.data`，不能 `return body`。返回整个 `{code,message,data}` 会让 `perms` 取到 `[]`，进而所有路由被过滤成空 |
| `src/router/index.ts` 兜底路由 | `/:pathMatch(.*)*` 必须**最后** `addRoute`（独立成 `fallbackRoute` 常量），否则动态路由注册前它就抢先匹配，全站被弹到 `/dashboard` |
| `src/layout/index.vue` 菜单过滤 | 有子菜单的分组必须**至少有一个有权限的子项**才渲染，否则整组退化成无路由可匹配的「死菜单」；无标题的单子项（如首页）直接渲染为一级菜单，避免出现空标题分组 |
| `sys_menu.icon` | 取值必须是 **Element Plus 图标组件名**（`Setting`/`Tools`/`Money`…），不能是小写别名。菜单维护页的图标选择器也不能直接 `v-for` 遍历 `@element-plus/icons-vue` 命名空间（拿到的是组件对象，选项会全部失效），须 `Object.keys()` 取名字，并用 `resolveIcon()` 兼容历史小写值 |
| `sys_menu` 种子 SQL | 菜单 INSERT 的 `ON DUPLICATE KEY UPDATE` 需要覆盖 `parent_id/path/component/icon/perm/sort`，只更新 `menu_name` 会导致老库改不动（图标、路径全是旧的） |
| `mybatis-plus.configuration.log-impl` | 用 `org.apache.ibatis.logging.slf4j.Slf4jImpl`，**不要用 `StdOutImpl`**：stdout 在后台窗口无人消费时会被写满阻塞，Tomcat 线程全部 BLOCKED，表现为所有接口挂起 |
| `application-*.yml` 的 JDBC URL | `characterEncoding` **必须是 `UTF-8`**，写 `utf8mb4` 会让 Connector/J 抛 `Unsupported character encoding`（驱动会自动映射到 utf8mb4） |
| `SysStorageConfigServiceImpl#saveAndApply` | MyBatis-Plus `BlockAttackInnerInterceptor` 只放行**含等值条件**的 UPDATE；`WHERE driver <> ?` 这类批量更新会被拦（`Prohibition of table update operation`），已改为按主键 `updateById` 逐条更新 |
| `SysStorageConfigServiceImpl#testConnection` | `LOCAL` 分支必须同样落库 `test_passed`，否则 `saveAndApply` 因恒为 0 而永远无法激活本地驱动 |
| `sql/99_init_data.sql` 的 `sys_user.password` | 必须是**真实可校验**的 BCrypt 哈希（已用 `spring-security-crypto` 验证 `Admin@123456`），伪造哈希会导致登录直接失败 |
| Redis `storage:active:driver` | 后端对该键使用 **JSON 序列化**，实际值是带引号的 `"LOCAL"`。不要用 `redis-cli set storage:active:driver LOCAL` 裸写；脚本/运维请走后台页面或 `POST /api/system/storage/test|apply?driver=LOCAL` 接口 |
| `scripts/*.ps1` 调接口 | PowerShell 的 splatting **只支持变量**（`$p=@{}; Invoke-RestMethod @p`），写成 `Invoke-RestMethod @{...}` 会把哈希表当成第一个位置参数（本机曾因此报 `Cannot bind parameter 'Uri'`），脚本已改为显式命名参数 |
| `scripts/*.ps1` 文件编码 | 全部须为 **UTF-8 with BOM**：Windows PowerShell 5.1 读取无 BOM 的 UTF-8 会按 ANSI 解码，中文注释/输出乱码 |
| `SysDictController#options` 路由顺序 | `@GetMapping("/options")` 必须写在基类 `BaseCrudController` 的 `@GetMapping("/{id}")` **之外/之前**（字面量路径优先于路径变量）。若把 options 交给基类匹配，会被 `/{id}` 抢先按 id 解析而 400 |
| `sys_dict_item` 唯一性 | 表上**没有** `(dict_type, item_value)` 唯一键，种子 SQL 若用普通 INSERT 会重复插行。必须写死主键 id（当前 1~98）并用 `ON DUPLICATE KEY UPDATE`；且 **id 1~21 已绑定 order_status / pay_type / crab_sex / ship_status**，新增字典项一律使用 ≥ 91 的空闲 id，不要重排已有 id，否则会串改线上数据 |
| 页面枚举取值来源 | 全站状态/类型/等级等**不再在页面里硬编码 `options: [...]`**，一律用 `Column.dict` / `Field.dict` 指向字典类型（`useDict.ts`）。注意字典里 tinyint 状态统一存字符串 `"1"/"0"`，比较时用 `String()`；新增枚举项要先在「字典管理」加，再加页面引用 |
| `src/components/ScanInput/index.vue` 打开摄像头 | `start()` 在「无摄像头/被浏览器拦截」时可能长时间不返回，必须保留 **8 秒超时兜底**（超时后提示改用扫码枪/手工录入），否则弹窗会永远停在「正在打开摄像头…」。另外 `html5-qrcode` 构造函数只接受**元素 id 字符串**，不要传 HTMLElement（会被 vue-tsc 报错） |
| `src/composables/useTable.ts` 的 `query` | 类型为 `Record<string, any>`。不要改回 `Record<string, unknown>`：`ScanInput`/`el-input` 的 `v-model` 绑定 `query.xxx` 会因类型不兼容导致 `vue-tsc` 报错 |
| 字典/引用表缓存刷新 | 字典管理页保存后必须 `loadDicts(true)` 强制刷新；其他页面在数据变更（新增/删除）后调 `clearLookups()` 再 `load()`，否则 id→名称 的映射会是旧的 |
| 小程序预览 `runtime.js#evalExpr` | 指令属性（`wx:if` / `wx:elif` / `wx:for`）的值**本身带 `{{ }}`**，求值前必须先剥掉花括号；否则 `new Function('with($s){return ({{x}})}')` 恒抛语法错，表现为「所有条件渲染与列表渲染静默失效、页面只剩静态骨架」 |
| 小程序预览 `runtime.js#requireFn` | 相对路径 `require('./config/index')` 的 base 必须补成**绝对 URL**（`location.origin + dir`）再交给 `new URL()`；只传 `/poyang-crab-miniapp/` 这类相对路径会抛 `Invalid URL`，且**不要**对已是绝对路径的 dir 再拼一次 origin |
| 小程序预览 `loadModule` 参数位 | 注入的 `App/Page/Component/getApp/getCurrentPages/console/setTimeout…` 顺序必须与形参一一对应（漏一个 `Component` 占位就会全体错位，`getApp()` 返回页面栈，页面报 `xxx is not a function`） |
| 小程序预览 `pageOptionsCache` | 页面模块被缓存后再次进入不会再执行 `Page()`，必须记住每个页面文件的配置兜底，否则二次进入（切 tab / 返回）报「页面未注册（Page() 未执行）」 |
| 小程序预览 `image` 的 `src` | 演示数据里 `images` 常是字符串 `"[]"`/`"{}"`，直接塞给 `img.src` 会让浏览器请求 `/[]` 并报 404；须与空串一起回退占位图 |

## 本轮改造验收记录（字典化 / 名称显示 / 扫码 / 筛选）

> 验收方式：后端接口实测（`curl`）+ 后台浏览器逐页实测（含增删改与筛选生效）。日期：2026-10-18。

| 需求 | 落地位置 | 验收证据 |
| --- | --- | --- |
| 全站枚举进字典并中文显示 | `sys_dict`(25 类) / `sys_dict_item`(97 项)、`SysDictController#options`、`useDict.ts` | `GET /system/dict/options` 返回 25 类；订单/支付/发货/审核/结算/等级/模式/来源/公母/平台等列表列与筛选一律中文 |
| 字典管理页（类型 + 字典项 CRUD） | `admin/src/views/system/dict/index.vue`、菜单 `id=7` | 页面左栏 24+ 类型、右栏按 `dictType` 过滤字典项；实测「新增字典项 → 业务页下拉即时出现 → 红色二次确认删除 → 列表消失」全通 |
| 状态都要进字典 | 待发货分拣/打包核验/出库发货（订单状态、发货状态、公母）、佣金、结算、报单、栏目、文章、卡券、会员、积分储值、支付流水、菜单维护 | 页面内已无 `options: [...]` 硬编码、无裸状态原文渲染（全仓库检索为空） |
| 商品管理：分类显示名称 | `product/list` 列 `lookup: productCategory` | 列表显示 礼盒装 / 鲜活湖蟹 / 批发大宗（原先为分类 ID） |
| 商品中心「分类管理」接线修正（既有缺陷） | `api/index.ts` 新增 `bizApi.productCategory = /product/category`；`product/category/index.vue` 改用它 | 该页原先错接 `/cms/category`，显示的是**内容栏目**（品牌故事…）。修正后显示真实商品分类（鲜活湖蟹/礼盒装/批发大宗），上级分类下拉为「顶级（不选）+ 3 个分类」，弹窗与内容栏目管理互不影响 |
| 商品管理：搜索补分类 + 销售模式 | `product/list` `filterFields` | UI 选「礼盒装」→ 查询 → 1 行；接口 `?categoryId=1`→1 条、`?sellMode=BOTH`→1 条 |
| 销售模式显示中文 | 列/表单 `dict: sell_mode` | 仅自营 / 仅批发 / 自营+批发 |
| 订单新增：订单号扫码 | `trade/order` 表单 `type: 'scan'` | 弹窗「订单号 [扫码]」；摄像头超时降级提示 + 扫码枪同输入框 |
| 评价管理新增商品名称 | `trade/review` 列 `lookup: product` | 列表显示 鄱阳湖大闸蟹·精品礼盒… |
| 待发货分拣状态进字典 | `ship/wait` 筛选项 + 列 | 列表显示 已支付 / 已发货 / 待支付（原先为英文枚举） |
| 打包核验顺丰运单号扫码 | `ship/wait`、`ship/pack` 弹窗 `ScanInput` | 弹窗「顺丰运单号 [扫码]」 |
| 凡带顺丰运单号处都可扫码 | `ship/outbound` 筛选 + 回填弹窗 `ScanInput` | 筛选扫码枪录入 `SF9876543210987` → 查询 → 1 行（请求按 `expressNo` 过滤） |
| 渠道档案：上级渠道下拉 | `channel/list` `Field: { type:'select', lookup:'channel', lookupTop }` | 列表显示「顶级 / 南昌蟹逅商贸有限公司」；弹窗下拉含「顶级（不选）」+ 全部渠道（不填落库 0 = 顶级） |
| 佣金规则：渠道商/来源渠道显示名称 | `channel/commission` 列/筛选 `lookup:'channel'` | 显示 南昌蟹逅商贸有限公司 / 九江鲜生优选（原先为 ID） |
| 佣金规则：结算状态进字典、来源渠道下拉 | `dict: settle_status`、`Field type:'select'` | 已结算 / 待结算 |
| 栏目管理：上级 ID 显示名称 + 下拉默认 0 | `cms/category` `lookup:'cmsCategory'` + `lookupTop` | 列表显示「顶级」；弹窗下拉「顶级（不选）+ 品牌故事/养殖基地/捕捞实景/招商合作/平台公告」 |
| 列表筛选原先全部为空操作 | `BaseCrudController#buildQuery`（属性名→列名、数字 eq、其它 like、固定主键排序） | 所有列表页筛选参数现在真实生效（订单号 / 分类 / 销售模式 / 运单号 / 状态…） |
| 回归 | 26 个后台路由全量遍历 | 全部 render，无 `code≠200` 接口、无 JS 报错；`vue-tsc --noEmit` EXIT=0；`npm run build` EXIT=0；H5 `:8849` HTTP 200；后端 `/api/actuator/health` = UP；两套小程序 JSON 合法 |

## 小程序浏览器预览验收记录（本机未装微信开发者工具）

> 背景：本机无微信开发者工具（`C:\Program Files (x86)\Tencent\微信web开发者工具\` 下无 `cli.bat`），
> 为「用浏览器打开看效果」新增 `scripts/miniapp-preview/`，同时把微信开发者工具的导入步骤补进两个小程序 README。日期：2026-10-18。

| 项 | 说明 |
| --- | --- |
| 启动 | `scripts\preview-miniapp.bat` → http://localhost:8850/preview/（双端并排）；`single.html?app=miniapp\|channel`（单端大屏）；`scripts\stop-all.bat` 统一停止 |
| 架构 | `server.mjs`（静态 + `/api` 反代 8080 + `/preview/token` 签发预览令牌）+ `runtime.js`（浏览器 mini-runtime）+ `ui.js`（设备壳 / 登录态 / 请求日志） |
| 登录态 | 用后端同一 JWT 密钥在本地签发预览令牌 → 注入 `CRAB_TOKEN`/`CRAB_USER`、`CHANNEL_TOKEN`/`CHANNEL_INFO`；顶部下拉切换 未登录 / 会员 1-3 / 渠道 1-2（默认会员 1 + 渠道 1） |
| 请求链路 | 页面内的 `http://localhost:8080/api` 自动改写为**同源** `/api` 再由 Node 反代，**不依赖**「不校验合法域名」与 CORS |

### C 端（poyang-crab-miniapp，11 页）

| 页面 | 实测结果 |
| --- | --- |
| `index/index` | 分类 + 商品卡（真实商品名 / ¥398.00 / 产地标签）+ 直播入口（`wx:if` 生效） |
| `product/detail`（`id=1`） | 公母 / 重量档 / 包装、SKU 价格、底部操作栏 |
| `cart/index` | 空态「购物车还是空的 去挑湖蟹」 |
| `order/confirm` | 地址选择 + 商品清单 + 订单备注 |
| `order/list` | 状态筛选 + `DD202610100001` 已支付 + 金额 |
| `order/detail`（`orderNo=DD202610100001`） | 收货信息 / 订单金额 / 运单区 |
| `logistics/index` | 顺丰冷链 + 运单号 `SF1234567890123` + 轨迹时间轴 |
| `review/index` | 总体评分 / 鲜活度 5 星 + 评价表单 |
| `article/index`（`id=1`） | 品牌文章（rich-text） |
| `member/index` | 登录态生效：昵称 / GOLD / 1280 积分 / ¥200 储值 |
| `login/index` | 已登录时自动 `navigateBack`（与小程序真实行为一致） |

交互实测：点击商品卡 → 详情（带 `id`）→ 返回栈回退 → tabBar 切「订单」→ 订单列表，全部正常。

### 渠道商端（poyang-crab-channel，9 页）

| 页面 | 实测结果 |
| --- | --- |
| `index/index` | 档案 + 编号 `CH2026001` + 授信/已用额度 + 待结算佣金 + 额度使用率 |
| `product/index` | 渠道专属价（仅批发商品 + 起订量） |
| `report/index` | 报单草稿 / 我的报单 |
| `mine/index` | 档案 + 额度 + 佣金 + 联系人 |
| `order/index` | 批发订单 + 状态筛选 + 明细 |
| `commission/index` | 待结算 ¥292.60 / 已结算 ¥31.84 + 明细（SALE +¥31.84） |
| `settlement/index` | 对账结算 + 额度流水 + 生成结算单 |
| `dealer/index` | 下级经销商团队（按 `parent_id` 反查） |
| `login/index` | 未登录进登录页；已登录直接进业务页 |

### 本轮同时修掉的预览缺陷（详见上方「勿回退」表）

`evalExpr` 花括号剥壳（条件/列表渲染全部失效）、`require` 相对路径 base、`loadModule` 参数错位（`getApp()` 不可用）、
二次进页「页面未注册（Page() 未执行）」、`images="[]"` 引起的 `/[]` 404 占位。

> ⚠️ 预览令牌仅限本机 `127.0.0.1` 使用，`/preview/token` **不得**暴露到生产环境。
