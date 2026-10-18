# 接口约定

## 一、基础信息

| 项 | 值 |
| --- | --- |
| Base URL | `https://api.xiegongzhu.com/api`（本地 `http://localhost:8080/api`） |
| context-path | `/api` |
| 数据格式 | `application/json; charset=utf-8` |
| 鉴权 | `Authorization: Bearer <JWT>` |
| 时间格式 | `yyyy-MM-dd HH:mm:ss`（`LocalDate` 为 `yyyy-MM-dd`） |
| 金额 | `BigDecimal`，单位 **元**，保留 2 位小数 |

## 二、统一响应体

```json
{ "code": 200, "message": "操作成功", "data": { } }
```

成功恒为 `code = 200`；`data` 为业务数据（可为对象、数组、`null`）。

### 分页结构 `PageResult`

```json
{ "records": [], "total": 100, "current": 1, "size": 10 }
```

分页请求统一参数：`current`（默认 1）、`size`（默认 10）。

## 三、业务状态码（`ResultCode`）

| code | 含义 |
| --- | --- |
| 200 | 操作成功 |
| 400 | 参数校验失败 |
| 401 | 未登录或登录已过期（前端需清 token 并跳登录） |
| 403 | 无操作权限 |
| 404 | 资源不存在 |
| 429 | 请求过于频繁 / 请勿重复提交（`@RateLimit`） |
| 452 | 内容含敏感词（`SensitiveWordService`） |
| 500 | 操作失败（未捕获异常统一兜底） |
| 1000 | 业务处理失败（`BizException` 默认） |
| 1001 | 库存不足 |
| 1002 | 订单状态不允许该操作 |
| 1003 | 对象存储未通过连接测试（T12：**测试通过才允许保存并应用**） |
| 1004 | 渠道报单需审核后才能转为正式订单 |

## 四、免登录白名单（`WebMvcConfig`）

```
/auth/**       后台账号登录
/portal/**     PC/H5/小程序公开数据（站点、导航、多语言、商品、文章、商品评价、招商申请）
/pay/notify/** 微信支付回调（回调侧做验签，不依赖 JWT）
/files/**      本地对象存储静态资源
/actuator/**   健康检查
/swagger-ui/** 接口文档（仅非生产）
```

其余路径一律需要 `Authorization: Bearer <token>`。

## 五、CRUD 约定（`BaseCrudController`）

除审计日志（只读）外，**所有业务模块的超管都具备完整增删改查**（PRO.md 6.2 红线）。继承基类即获得：

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| GET | `/{module}/page?current=&size=` | 分页（**带通用筛选**，见下） |
| GET | `/{module}/list` | 不分页列表 |
| GET | `/{module}/{id}` | 详情 |
| POST | `/{module}` | 新增 |
| PUT | `/{module}` | 修改 |
| DELETE | `/{module}/{id}` | 逻辑删除 |
| DELETE | `/{module}/batch` | 批量逻辑删除 |

### 5.1 分页通用筛选

`page` 除 `current` / `size` 外，可携带**任意实体属性名**作为查询条件（`BaseCrudController#page` 的 `@RequestParam Map<String,Object> params` + `TableInfoHelper` 做「属性名 → 列名」映射）：

| 传参示例 | 生成条件 | 说明 |
| --- | --- | --- |
| `?categoryId=1` | `category_id = 1` | 值全为数字 → 等值 |
| `?sellMode=BOTH` | `sell_mode LIKE '%BOTH%'` | 非纯数字 → 模糊 |
| `?orderNo=DD2026` | `order_no LIKE '%DD2026%'` | 订单号/运单号同理 |
| `?current=1&size=10` | `ORDER BY id ASC LIMIT ...` | 固定按主键排序，避免分页漂移 |

未匹配到列的参数会被忽略；`current` / `size` 由 MyBatis-Plus 分页插件处理。

### 5.2 字典与枚举（`sys_dict` / `sys_dict_item`）

全站枚举（状态 / 类型 / 等级 / 审核状态 / 支付状态 / 变动类型 …）统一落字典表，由「系统管理 → 字典管理」维护，前端按下发的**值**显示中文：

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| GET | `/system/dict/options` | 一次性返回全部字典（`{ 字典类型: [{label, value}] }`），仅含 `status=1` 的项，按 `sort` 排序 |
| GET | `/system/dict/page?current=&size=` | 字典类型分页（字典管理页左栏） |
| GET | `/system/dict-item/page?current=&size=&dictType=` | 指定类型下的字典项分页（右栏） |
| POST/PUT/DELETE | `/system/dict`、`/system/dict-item` | 字典类型 / 字典项的增删改（超管） |

约定：字典项 `itemValue` 一律**字符串**存储（tinyint 状态存 `"1"/"0"`，前端用 `String()` 比较）；新增枚举项要先在字典管理里加，页面再引用，**不要在页面硬编码选项**。

有特殊语义的操作**不放在通用 CRUD 中**，而是独立 `@RequestMapping` 的子路径，例如：

- 交易主流程：`/order/create`、`/order/pay`、`/order/ship`、`/order/confirm`、`/order/cancel`
- 我的订单（归属校验只读）：`/order/my/page`、`/order/my/by-no/{orderNo}`、`/order/my/items`、`/order/my/delivery`
- 渠道商业务：`/channel/biz/**`
- 登录态相关：`/member/profile`、`/trade/review/submit`、`/trade/review/my`

## 六、安全与审计约定

1. **归属校验**：C 端只读接口一律从登录态取 `memberId` / `channelId`，**禁止前端传主体 ID**（`OrderQueryController#assertOwner`）。
2. **敏感字段不外发**：`openid` / `unionid` / 密钥 / 证照图片在 C 端与渠道端接口中一律置空。
3. **审计留痕**：写操作标注 `@AuditLog(module, operation, saveParam)`，落 `sys_audit_log`。
4. **限流防重**：下单、支付、登录、评价、轨迹查询等标注 `@RateLimit`。
5. **比例快照**：佣金计算时把当次 `rate` 落库（`t_commission.rate`），后续调参不影响历史账。

## 七、命名规范

| 项 | 规范 | 示例 |
| --- | --- | --- |
| 表名 | `t_` 前缀 + 小写下划线 | `t_order`、`t_channel` |
| 字段 | 小写下划线 | `order_status`、`created_at` 风格的 `create_time` |
| 主键 | `id`（雪花/自增，见 `BaseEntity`） | — |
| 逻辑删除 | `deleted`（0 正常 / 1 删除） | MyBatis-Plus 全局配置 |
| 乐观锁 | `version` | 库存、订单并发 |
| 业务单号 | 前缀 + 时间戳/雪花 | `DD` 订单、`BD` 报单、`YJ` 佣金、`JS` 结算 |
| 枚举值 | 大写下划线，字典落 `sys_dict_item` | `UNPAID`、`PENDING`、`APPROVED` |
