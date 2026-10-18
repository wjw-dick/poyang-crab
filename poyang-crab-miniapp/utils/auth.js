/**
 * 登录辅助：微信一键登录（code -> 后端换取 JWT）
 * 后端对应接口：POST /wx/login （WxAuthController，按 UnionID 打通公众号/小程序/H5）
 */
const request = require('./request')

function isLogin() {
  return !!wx.getStorageSync('CRAB_TOKEN')
}

function setSession(token, userInfo) {
  wx.setStorageSync('CRAB_TOKEN', token || '')
  wx.setStorageSync('CRAB_USER', userInfo || null)
  const app = getApp()
  if (app && app.globalData) {
    app.globalData.token = token || ''
    app.globalData.userInfo = userInfo || null
  }
}

/** 微信登录：wx.login 取 code，交给后端换 openid/unionid + 签发 JWT */
function wxLogin(extra = {}) {
  return new Promise((resolve, reject) => {
    wx.login({
      success(res) {
        if (!res.code) {
          reject(new Error('获取微信 code 失败'))
          return
        }
        // 后端 WxAuthController#login 为 @RequestParam，需以 query 形式传递
        request
          .post('/wx/login?code=' + encodeURIComponent(res.code) + '&source=' + (extra.source || 'MINIAPP'), {}, { auth: false })
          .then((data) => {
            setSession(data.token, data)
            resolve(data)
          })
          .catch(reject)
      },
      fail: reject
    })
  })
}

/**
 * 手机号授权绑定
 * TODO(T18) 后端暂未提供 /wx/bind-phone，需在 MemberAuthService 中实现
 * AppID 解密（encryptedData + iv）后再放开此调用。
 */
function bindPhone(code, detail) {
  return request.post(
    '/wx/bind-phone?code=' + encodeURIComponent(code || ''),
    { encryptedData: detail && detail.encryptedData, iv: detail && detail.iv }
  )
}

module.exports = { isLogin, setSession, wxLogin, bindPhone }
