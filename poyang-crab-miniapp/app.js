/**
 * T23 小程序端主入口
 * 说明：本项目为骨架级脚手架，业务逻辑以 TODO(Txx) 标注，接口已按后端 PortalController / WxAuthController 对齐。
 */
const { BASE_URL } = require('./config/index')
const request = require('./utils/request')

App({
  globalData: {
    baseUrl: BASE_URL,
    /** 登录态与用户信息，由 utils/request 在收到 401 时自动清理 */
    token: '',
    userInfo: null,
    /** 站点头部信息，来自 /portal/site，避免每个页面重复请求 */
    site: {},
    /** 购物车本地缓存，登录后可与服务端合并 */
    cart: []
  },

  onLaunch() {
    this.restoreSession()
    this.loadSiteConfig()
    this.initCart()
  },

  onShow() {
    // TODO(T23) 从直播间/分享卡片进入时，解析 scene 参数并做埋点
  },

  onError(err) {
    // TODO(T21) 前端异常统一上报（可复用后台 audit 上报接口）
    console.error('[app error]', err)
  },

  /** 恢复本地登录态 */
  restoreSession() {
    const token = wx.getStorageSync('CRAB_TOKEN')
    const userInfo = wx.getStorageSync('CRAB_USER')
    if (token) {
      this.globalData.token = token
      this.globalData.userInfo = userInfo || null
    }
  },

  /** 拉取站点公开参数（客服电话 / ICP / 品牌名），密钥字段后端已过滤 */
  loadSiteConfig() {
    request
      .get('/portal/site', {}, { auth: false })
      .then((data) => {
        this.globalData.site = data || {}
      })
      .catch(() => {
        // 公开接口失败不阻塞启动
      })
  },

  /** 购物车本地初始化 */
  initCart() {
    this.globalData.cart = wx.getStorageSync('CRAB_CART') || []
  },

  /** 保存购物车并同步到 globalData */
  saveCart(cart) {
    this.globalData.cart = cart || []
    wx.setStorageSync('CRAB_CART', this.globalData.cart)
    return this.globalData.cart
  },

  /** 退出登录 */
  logout() {
    this.globalData.token = ''
    this.globalData.userInfo = null
    wx.removeStorageSync('CRAB_TOKEN')
    wx.removeStorageSync('CRAB_USER')
  }
})
