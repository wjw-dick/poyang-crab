/**
 * T25/T27 渠道商工作台：渠道档案 + 额度 + 待结算佣金 + 快捷入口
 */
const { channelApi } = require('../../api/index')
const { money, percent, textOf, CHANNEL_STATUS_TEXT } = require('../../utils/format')

const QUICK_ENTRIES = [
  { key: 'report', label: '我要报单', desc: '提交批发需求', url: '/pages/report/index' },
  { key: 'product', label: '渠道专属价', desc: '查看批发价', url: '/pages/product/index' },
  { key: 'order', label: '批发订单', desc: '查看发货进度', url: '/pages/order/index' },
  { key: 'commission', label: '我的佣金', desc: '分佣与返佣', url: '/pages/commission/index' },
  { key: 'settlement', label: '对账结算', desc: '生成结算单', url: '/pages/settlement/index' },
  { key: 'dealer', label: '下级经销商', desc: '团队与返佣', url: '/pages/dealer/index' }
]

Page({
  data: {
    channel: null,
    statusText: '',
    overview: {},
    quotaPercent: 0,
    usedQuotaText: '0.00',
    creditQuotaText: '0.00',
    pendingCommissionText: '0.00',
    commissionRateText: '0%',
    referralRateText: '0%',
    quickEntries: QUICK_ENTRIES,
    loaded: false
  },

  onShow() {
    if (!getApp().requireChannel()) {
      this.setData({ loaded: true })
      return
    }
    this.setData({ channel: getApp().globalData.channel })
    this.loadOverview()
  },

  onPullDownRefresh() {
    this.loadOverview()
    wx.stopPullDownRefresh()
  },

  loadOverview() {
    channelApi
      .overview()
      .then((data) => {
        const channel = (data && data.channel) || this.data.channel
        const creditQuota = Number((data && data.creditQuota) || 0)
        const usedQuota = Number((data && data.usedQuota) || 0)
        getApp().globalData.channel = channel
        wx.setStorageSync('CHANNEL_INFO', channel)
        this.setData({
          channel,
          overview: data || {},
          statusText: textOf(CHANNEL_STATUS_TEXT, channel && channel.status),
          usedQuotaText: money(usedQuota),
          creditQuotaText: money(creditQuota),
          quotaPercent: creditQuota > 0 ? Math.min(100, Math.round((usedQuota / creditQuota) * 100)) : 0,
          pendingCommissionText: money((data && data.pendingCommission) || 0),
          commissionRateText: percent((data && data.commissionRate) || (data && data.defaultCommissionRate) || 0),
          referralRateText: percent((data && data.referralRate) || (data && data.defaultReferralRate) || 0),
          loaded: true
        })
      })
      .catch(() => this.setData({ loaded: true }))
  },

  onEntryTap(e) {
    wx.navigateTo({ url: e.currentTarget.dataset.url })
  },

  onQuotaDetail() {
    wx.navigateTo({ url: '/pages/settlement/index?tab=quota' })
  },

  onLogin() {
    wx.reLaunch({ url: '/pages/login/index' })
  }
})
