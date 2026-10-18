/**
 * T25 渠道商「我的」：档案信息 + 业务入口 + 退出登录
 */
const { channelApi } = require('../../api/index')
const { money, textOf, CHANNEL_STATUS_TEXT } = require('../../utils/format')

const LINKS = [
  { key: 'order', label: '批发订单', url: '/pages/order/index' },
  { key: 'commission', label: '我的佣金', url: '/pages/commission/index' },
  { key: 'settlement', label: '对账结算', url: '/pages/settlement/index' },
  { key: 'dealer', label: '下级经销商', url: '/pages/dealer/index' },
  { key: 'report', label: '我的报单', url: '/pages/report/index' }
]

Page({
  data: {
    channel: null,
    statusText: '',
    usedQuotaText: '0.00',
    creditQuotaText: '0.00',
    pendingCommissionText: '0.00',
    overview: {},
    links: LINKS
  },

  onShow() {
    const app = getApp()
    if (!app.requireChannel()) {
      wx.reLaunch({ url: '/pages/login/index' })
      return
    }
    this.setData({ channel: app.globalData.channel })
    channelApi
      .overview()
      .then((data) =>
        this.setData({
          overview: data || {},
          channel: (data && data.channel) || this.data.channel,
          statusText: textOf(CHANNEL_STATUS_TEXT, data && data.channel && data.channel.status),
          usedQuotaText: money((data && data.usedQuota) || 0),
          creditQuotaText: money((data && data.creditQuota) || 0),
          pendingCommissionText: money((data && data.pendingCommission) || 0)
        })
      )
      .catch(() => {})
  },

  onLinkTap(e) {
    wx.navigateTo({ url: e.currentTarget.dataset.url })
  },

  onCallService() {
    const phone = (getApp().globalData.site || {}).servicePhone
    if (phone) {
      wx.makePhoneCall({ phoneNumber: phone })
    } else {
      wx.showToast({ title: '平台热线未配置', icon: 'none' })
    }
  },

  onLogout() {
    wx.showModal({
      title: '退出登录',
      content: '确认退出渠道商账号？',
      confirmColor: '#E4393C',
      success: (res) => {
        if (!res.confirm) return
        getApp().logout()
        wx.reLaunch({ url: '/pages/login/index' })
      }
    })
  },

  onCopyChannelNo() {
    const no = this.data.channel && this.data.channel.channelNo
    if (no) {
      wx.setClipboardData({ data: no })
    }
  }
})
