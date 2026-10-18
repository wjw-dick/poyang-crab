/**
 * T25 渠道商端统一请求封装
 * 与 C 端一致：自动带 JWT、统一解包 {code,message,data}、401 跳登录。
 * 差异：令牌存储 key 为 CHANNEL_TOKEN，登录失败跳 pages/login/index。
 */
const { BASE_URL } = require('../config/index')

function buildToken() {
  const token = wx.getStorageSync('CHANNEL_TOKEN')
  return token ? { Authorization: 'Bearer ' + token } : {}
}

function handleUnauthorized() {
  wx.removeStorageSync('CHANNEL_TOKEN')
  wx.removeStorageSync('CHANNEL_INFO')
  const app = getApp()
  if (app && app.globalData) {
    app.globalData.token = ''
    app.globalData.channel = null
  }
  wx.reLaunch({ url: '/pages/login/index' })
}

function request(options) {
  const { url, method = 'GET', data = {}, header = {}, auth = true, loading = false } = options

  return new Promise((resolve, reject) => {
    if (loading) {
      wx.showLoading({ title: '加载中', mask: true })
    }
    wx.request({
      url: BASE_URL + url,
      method,
      data,
      header: Object.assign({ 'Content-Type': 'application/json' }, auth ? buildToken() : {}, header),
      success(res) {
        const body = res.data
        if (res.statusCode === 401) {
          handleUnauthorized()
          reject(new Error('登录已过期'))
          return
        }
        if (res.statusCode !== 200) {
          wx.showToast({ title: '网络异常(' + res.statusCode + ')', icon: 'none' })
          reject(new Error('HTTP ' + res.statusCode))
          return
        }
        if (!body || typeof body.code !== 'number') {
          resolve(body)
          return
        }
        if (body.code === 200) {
          resolve(body.data)
          return
        }
        wx.showToast({ title: body.message || '请求失败', icon: 'none' })
        reject(new Error(body.message || '请求失败'))
      },
      fail(err) {
        wx.showToast({ title: '网络连接失败', icon: 'none' })
        reject(err)
      },
      complete() {
        if (loading) {
          wx.hideLoading()
        }
      }
    })
  })
}

module.exports = {
  BASE_URL,
  request,
  get: (url, data, opts) => request(Object.assign({ url, method: 'GET', data }, opts)),
  post: (url, data, opts) => request(Object.assign({ url, method: 'POST', data }, opts)),
  put: (url, data, opts) => request(Object.assign({ url, method: 'PUT', data }, opts)),
  del: (url, data, opts) => request(Object.assign({ url, method: 'DELETE', data }, opts))
}
