/**
 * T25 渠道商登录：微信登录 + 绑定渠道档案校验
 * 说明：渠道商账号由后台在「渠道商管理」中维护（t_channel.union_id）；
 * 未绑定渠道档案的微信号登录后会被拒绝，需联系平台管理员开通。
 */
const request = require('./request')

function isLogin() {
  const app = getApp()
  return !!(app && app.globalData.token && app.globalData.channel)
}

/** 微信登录并拉取渠道档案 */
function login() {
  return new Promise((resolve, reject) => {
    wx.login({
      success(res) {
        if (!res.code) {
          reject(new Error('获取微信 code 失败'))
          return
        }
        request
          .post('/wx/login?code=' + encodeURIComponent(res.code) + '&source=CHANNEL', {}, { auth: false })
          .then((data) => {
            // 先落 token，/channel/biz/profile 需要携带
            wx.setStorageSync('CHANNEL_TOKEN', data.token || '')
            getApp().globalData.token = data.token || ''
            return request.get('/channel/biz/profile')
          })
          .then((channel) => {
            if (!channel) {
              reject(new Error('当前微信号未绑定渠道商档案，请联系平台管理员'))
              return
            }
            getApp().saveChannel(getApp().globalData.token, channel)
            resolve(channel)
          })
          .catch((err) => {
            // 绑定失败时清掉临时 token，避免半登录状态
            getApp().logout()
            reject(err)
          })
      },
      fail: reject
    })
  })
}

function logout() {
  getApp().logout()
}

module.exports = { isLogin, login, logout }
