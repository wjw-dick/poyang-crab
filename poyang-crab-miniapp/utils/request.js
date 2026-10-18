/**
 * T23 统一网络请求封装
 * - 自动拼接 BASE_URL 与 Authorization: Bearer <token>
 * - 统一解包后端 { code, message, data } 响应体（成功 code=200）
 * - 401 自动清理登录态并跳转登录页
 */
const { BASE_URL } = require('../config/index')

const WHITE_LIST = ['/portal/site', '/portal/nav', '/portal/i18n', '/portal/product', '/portal/category', '/portal/article']

function isWhite(url) {
  return WHITE_LIST.some((prefix) => url.indexOf(prefix) === 0)
}

function buildToken() {
  const token = wx.getStorageSync('CRAB_TOKEN')
  return token ? { Authorization: 'Bearer ' + token } : {}
}

function handleUnauthorized() {
  wx.removeStorageSync('CRAB_TOKEN')
  wx.removeStorageSync('CRAB_USER')
  const app = getApp()
  if (app && app.globalData) {
    app.globalData.token = ''
    app.globalData.userInfo = null
  }
  wx.navigateTo({ url: '/pages/login/index' })
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
      header: Object.assign({ 'Content-Type': 'application/json' }, auth && !isWhite(url) ? buildToken() : {}, header),
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
        // 业务失败：统一 toast，调用方可 catch 后自行处理
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
