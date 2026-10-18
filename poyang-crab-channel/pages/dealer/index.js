/**
 * T27 下级经销商：团队列表 + 转介绍返佣比例 + 邀请入口
 * 后端：GET /channel/biz/dealer/list（按 parent_id 反查，已脱敏 unionId / 证照）
 */
const { channelApi } = require('../../api/index')
const { money, percent, formatDate, textOf, CHANNEL_STATUS_TEXT } = require('../../utils/format')

Page({
  data: {
    dealers: [],
    referralRateText: '0%',
    childCount: 0,
    loading: true
  },

  onShow() {
    this.load()
  },

  onPullDownRefresh() {
    this.load()
    wx.stopPullDownRefresh()
  },

  load() {
    const app = getApp()
    if (!app.requireChannel()) {
      wx.reLaunch({ url: '/pages/login/index' })
      return
    }
    this.setData({ loading: true })
    channelApi
      .overview()
      .then((data) =>
        this.setData({
          referralRateText: percent((data && data.referralRate) || (data && data.defaultReferralRate) || 0),
          childCount: (data && data.childCount) || 0
        })
      )
      .catch(() => {})
    channelApi
      .dealers()
      .then((list) =>
        this.setData({
          dealers: (list || []).map((item) =>
            Object.assign({}, item, {
              statusText: textOf(CHANNEL_STATUS_TEXT, item.status),
              commissionRateText: percent(item.commissionRate),
              referralRateText: percent(item.referralRate),
              usedQuotaText: money(item.usedQuota),
              timeText: formatDate(item.createTime)
            })
          )
        })
      )
      .catch(() => {})
      .then(() => this.setData({ loading: false }))
  },

  onInvite() {
    // TODO(T27) 生成带上级渠道 ID 的邀请码/小程序码，下级注册后自动挂靠 parent_id
    wx.showModal({
      title: '邀请下级经销商',
      content: '邀请功能待后端提供邀请码接口（T27）后开放，届时下级渠道商会自动挂靠为您的下级。',
      showCancel: false
    })
  },

  onCallDealer(e) {
    const mobile = e.currentTarget.dataset.mobile
    if (mobile) {
      wx.makePhoneCall({ phoneNumber: mobile })
    } else {
      wx.showToast({ title: '暂无联系电话', icon: 'none' })
    }
  }
})
