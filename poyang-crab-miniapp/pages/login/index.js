/**
 * T18/T23 微信登录：wx.login -> 后端 /wx/login（按 UnionID 打通公众号/小程序/H5 会员）
 */
const { wxLogin, isLogin } = require('../../utils/auth')

Page({
  data: {
    agreed: true,
    loading: false,
    site: {}
  },

  onLoad() {
    const app = getApp()
    this.setData({ site: app.globalData.site || {} })
    if (isLogin()) {
      wx.navigateBack()
    }
  },

  onAgreeChange(e) {
    this.setData({ agreed: e.detail.value.length > 0 })
  },

  onLogin() {
    if (!this.data.agreed) {
      wx.showToast({ title: '请先同意用户协议与隐私政策', icon: 'none' })
      return
    }
    if (this.data.loading) return
    this.setData({ loading: true })

    wxLogin({ source: 'MINIAPP' })
      .then(() => {
        wx.showToast({ title: '登录成功', icon: 'success' })
        setTimeout(() => {
          const pages = getCurrentPages()
          if (pages.length > 1) {
            wx.navigateBack()
          } else {
            wx.switchTab({ url: '/pages/index/index' })
          }
        }, 600)
      })
      .catch(() => {
        wx.showToast({ title: '登录失败，请重试', icon: 'none' })
      })
      .then(() => this.setData({ loading: false }))
  },

  /** 手机号授权（需企业主体 + 已开通能力） */
  onGetPhone(e) {
    const { bindPhone } = require('../../utils/auth')
    // TODO(T18) 后端 /wx/bind-phone 未实现，先提示占位
    wx.showToast({ title: '手机号绑定待接入', icon: 'none' })
    console.warn('[bind phone]', e.detail)
    bindPhone(e.detail.code, e.detail)
  },

  onViewAgreement() {
    // TODO(T23) 接入《用户协议》《隐私政策》静态页（可由 CMS 文章承载）
    wx.showToast({ title: '协议内容待接入 CMS', icon: 'none' })
  }
})
