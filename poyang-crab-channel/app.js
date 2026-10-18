/**
 * T25-T28 渠道商端小程序主入口
 * 面向角色：CHANNEL（渠道商 / 经销商 / 代理），报单、渠道专属价、佣金、额度、对账结算。
 * 说明：骨架级脚手架，业务逻辑以 TODO(Txx) 标注。
 */
const { BASE_URL } = require('./config/index')
const request = require('./utils/request')

App({
  globalData: {
    baseUrl: BASE_URL,
    token: '',
    /** 当前登录渠道商档案（t_channel） */
    channel: null,
    site: {},
    /** 报单草稿（本地暂存，避免误退出丢失） */
    reportDraft: []
  },

  onLaunch() {
    this.restoreSession()
    this.loadSiteConfig()
    this.globalData.reportDraft = wx.getStorageSync('CHANNEL_REPORT_DRAFT') || []
  },

  restoreSession() {
    const token = wx.getStorageSync('CHANNEL_TOKEN')
    const channel = wx.getStorageSync('CHANNEL_INFO')
    if (token) {
      this.globalData.token = token
      this.globalData.channel = channel || null
    }
  },

  loadSiteConfig() {
    request
      .get('/portal/site', {}, { auth: false })
      .then((data) => {
        this.globalData.site = data || {}
      })
      .catch(() => {})
  },

  /** 渠道商必登：未登录或未绑定渠道档案时跳转登录页 */
  requireChannel() {
    return !!this.globalData.token && !!this.globalData.channel
  },

  saveChannel(token, channel) {
    this.globalData.token = token || ''
    this.globalData.channel = channel || null
    wx.setStorageSync('CHANNEL_TOKEN', this.globalData.token)
    wx.setStorageSync('CHANNEL_INFO', this.globalData.channel)
  },

  saveReportDraft(items) {
    this.globalData.reportDraft = items || []
    wx.setStorageSync('CHANNEL_REPORT_DRAFT', this.globalData.reportDraft)
    return this.globalData.reportDraft
  },

  logout() {
    this.globalData.token = ''
    this.globalData.channel = null
    wx.removeStorageSync('CHANNEL_TOKEN')
    wx.removeStorageSync('CHANNEL_INFO')
  }
})
