/**
 * T23 C 端小程序接口层
 * 全部对齐后端既有 Controller；标记 TODO 的接口在后端为骨架实现，需按 Txx 补齐。
 */
const request = require('../utils/request')

/** 门户/公开数据（免登录，对应 PortalController） */
const portalApi = {
  site: () => request.get('/portal/site', {}, { auth: false }),
  nav: (platform = 'MINIAPP') => request.get('/portal/nav', { platform }, { auth: false }),
  i18n: (langCode) => request.get(`/portal/i18n/${langCode}`, {}, { auth: false }),
  categories: () => request.get('/portal/category/list', {}, { auth: false }),
  productList: (params) => request.get('/portal/product/list', params || {}, { auth: false }),
  productDetail: (id) => request.get(`/portal/product/${id}`, {}, { auth: false }),
  articles: (categoryCode) => request.get('/portal/article/list', { categoryCode }, { auth: false }),
  article: (id) => request.get(`/portal/article/${id}`, {}, { auth: false })
}

/** 微信登录 */
const authApi = {
  /** 用 wx.login 的 code 换取 JWT（后端为 @RequestParam） */
  login: (code, source = 'MINIAPP') => request.post(`/wx/login?code=${encodeURIComponent(code)}&source=${source}`, {}, { auth: false })
}

/** 会员中心（会员 / 地址 / 积分 / 储值 / 卡券） */
const memberApi = {
  /** 当前登录会员（后端 /member/profile，已脱敏 openid/unionid） */
  profile: () => request.get('/member/profile'),
  addresses: () => request.get('/member/address/list'),
  addressSave: (data) => (data.id ? request.put('/member/address', data) : request.post('/member/address', data)),
  addressDelete: (id) => request.del(`/member/address/${id}`),
  pointLogs: (params) => request.get('/member/point-log/page', params || { current: 1, size: 20 }),
  balanceLogs: (params) => request.get('/member/balance-log/page', params || { current: 1, size: 20 }),
  coupons: (params) => request.get('/member/coupon/page', params || { current: 1, size: 20 })
}

/** 购物车 */
const cartApi = {
  list: () => request.get('/cart/list'),
  add: (data) => request.post('/cart', data),
  update: (data) => request.put('/cart', data),
  remove: (id) => request.del(`/cart/${id}`)
}

/** 订单交易 */
const orderApi = {
  create: (data) => request.post('/order/create', data),
  /** 返回 wx.requestPayment 所需参数 */
  pay: (orderNo, payType = 'WECHAT', openId) =>
    request.post(`/order/pay?orderNo=${orderNo}&payType=${payType}${openId ? '&openId=' + openId : ''}`),
  confirm: (orderNo) => request.post(`/order/confirm?orderNo=${orderNo}`),
  cancel: (orderNo) => request.post(`/order/cancel?orderNo=${orderNo}`),
  /** 后台发货端使用；小程序仅用于售后台展示 */
  ship: (orderNo, expressNo, packCheck) =>
    request.post(`/order/ship?orderNo=${orderNo}&expressNo=${expressNo}${packCheck ? '&packCheck=' + packCheck : ''}`),
  /** 我的订单（后端 /order/my/page，按登录会员过滤，禁止越权） */
  list: (params) => request.get('/order/my/page', params || { current: 1, size: 10 }),
  /** 订单详情（按订单号，后端做归属校验） */
  detailByNo: (orderNo) => request.get(`/order/my/by-no/${orderNo}`),
  detail: (id) => request.get(`/order/my/by-no/${id}`),
  items: (orderId) => request.get('/order/my/items', { orderId }),
  delivery: (orderId) => request.get('/order/my/delivery', { orderId })
}

/** 评价 */
const reviewApi = {
  /** 发表评价：memberId 由后端从登录态注入，前端不得传递 */
  create: (data) => request.post('/trade/review/submit', data),
  myList: (params) => request.get('/trade/review/my', params || { current: 1, size: 10 }),
  productReviews: (productId, params) =>
    request.get('/portal/review/list', Object.assign({ productId, limit: 20 }, params || {}), { auth: false })
}

/** 直播（T23 直播间关联商品） */
const liveApi = {
  list: () => request.get('/live/page', { current: 1, size: 10 }, { auth: false }),
  detail: (id) => request.get(`/live/${id}`, {}, { auth: false })
}

module.exports = { portalApi, authApi, memberApi, cartApi, orderApi, reviewApi, liveApi }
