/**
 * T25-T28 渠道商端接口层
 * 全部对齐 ChannelBizController（/channel/biz/**），该组接口会自动根据登录态解析 channelId，
 * 前端不需要（也不应该）传 channelId。
 */
const request = require('../utils/request')

const authApi = {
  /** 微信登录（source=CHANNEL），后端按 UnionID 识别 */
  login: (code, source = 'CHANNEL') =>
    request.post('/wx/login?code=' + encodeURIComponent(code) + '&source=' + source, {}, { auth: false })
}

const channelApi = {
  /** 当前渠道商档案 */
  profile: () => request.get('/channel/biz/profile'),
  /** 工作台概览：额度 / 待结算佣金 / 下级数 / 起订量与比例配置 */
  overview: () => request.get('/channel/biz/overview'),
  quotaLogs: () => request.get('/channel/biz/quota/logs'),

  /** T26 渠道专属价商品（含 SKU 批发价） */
  products: (keyword) => request.get('/channel/biz/product/list', { keyword }),

  /** T25 报单：body 为 [{skuId, qty}] */
  submitReport: (items) => request.post('/channel/biz/report/submit', items),
  reportPage: (params) => request.get('/channel/biz/report/page', Object.assign({ current: 1, size: 10 }, params || {})),

  /** T27 佣金 */
  commissionPage: (params) => request.get('/channel/biz/commission/page', Object.assign({ current: 1, size: 10 }, params || {})),

  /** T28 对账结算 */
  settlementPage: (params) => request.get('/channel/biz/settlement/page', Object.assign({ current: 1, size: 10 }, params || {})),
  createSettlement: (start, end) => request.get('/channel/biz/settlement/create', { start, end }),
  confirmSettlement: (settleNo) => request.post('/channel/biz/settlement/' + settleNo + '/confirm'),

  /** 下级经销商 */
  dealers: () => request.get('/channel/biz/dealer/list'),

  /** 批发订单（后端 /order/my/page：渠道端按 channel_id 过滤 + bizMode=WHOLESALE） */
  orderPage: (params) =>
    request.get('/order/my/page', Object.assign({ current: 1, size: 10, bizMode: 'WHOLESALE' }, params || {})),
  orderItems: (orderId) => request.get('/order/my/items', { orderId })
}

const portalApi = {
  site: () => request.get('/portal/site', {}, { auth: false })
}

module.exports = { authApi, channelApi, portalApi }
