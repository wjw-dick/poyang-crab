/**
 * T25 渠道商端登录：微信授权 + 渠道档案校验
 */
const { login } = require('../../utils/auth')

Page({
  data: {
    loading: false,
    site: {}
  },

  onLoad() {
    this.setData({ site: getApp().globalData.site || {} })
  },

  onLogin() {
    if (this.data.loading) return
    this.setData({ loading: true })
    login()
      .then((channel) => {
        wx.showToast({ title: '登录成功', icon: 'success' })
        setTimeout(() => wx.switchTab({ url: '/pages/index/index' }), 600)
        console.warn('[channel login]', channel && channel.channelName)
      })
      .catch((err) => {
        wx.showModal({
          title: '登录失败',
          content: err && err.message ? err.message : '请稍后重试',
          showCancel: false,
          confirmText: '知道了'
        })
      })
      .then(() => this.setData({ loading: false }))
  },

  onApply() {
    // TODO(T25) 未成为渠道商：跳转招商申请表（可复用 /portal/channel-apply）
    wx.showModal({
      title: '成为渠道商',
      content: '请先在招商页面提交合作申请，平台审核通过后由管理员开通渠道商账号。',
      showCancel: false
    })
  }
})
