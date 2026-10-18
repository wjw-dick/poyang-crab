/**
 * T24 确认订单：收货地址 + 商品清单 + 备注 + 提交下单 + 微信支付
 */
const { memberApi, orderApi } = require('../../api/index')
const { money, splitPrice } = require('../../utils/format')

Page({
  data: {
    items: [],
    address: null,
    remark: '',
    freight: 0,
    totalAmount: '0.00',
    payableAmount: '0.00',
    payableParts: splitPrice(0),
    submitting: false
  },

  onLoad(options) {
    const items = wx.getStorageSync('CRAB_CHECKOUT_ITEMS') || []
    this.setData({ items })
    this.loadDefaultAddress()
    this.calcAmount(items)
  },

  loadDefaultAddress() {
    memberApi
      .addresses()
      .then((list) => {
        const address = (list || []).find((item) => item.isDefault === 1) || (list || [])[0] || null
        this.setData({ address })
      })
      .catch(() => {})
  },

  calcAmount(items) {
    const goodsTotal = items.reduce((sum, item) => sum + Number(item.price || 0) * Number(item.quantity || 0), 0)
    // TODO(T24) 运费规则（满额包邮/偏远地区补差）应从系统参数读取，禁止写死
    const freight = goodsTotal >= 199 ? 0 : 20
    const payable = goodsTotal + freight
    this.setData({
      freight,
      totalAmount: money(goodsTotal),
      payableAmount: money(payable),
      payableParts: splitPrice(payable)
    })
  },

  onSelectAddress() {
    wx.navigateTo({ url: '/pages/member/index?tab=address&select=1' })
  },

  onRemarkInput(e) {
    this.setData({ remark: e.detail.value })
  },

  /** 提交 → 下单 → 拉起微信支付 */
  onSubmit() {
    if (this.data.submitting) return
    const address = this.data.address
    if (!address) {
      wx.showToast({ title: '请选择收货地址', icon: 'none' })
      return
    }
    const items = this.data.items.filter((item) => item.skuId)
    if (!items.length) {
      wx.showToast({ title: '商品规格缺失，请重新选择', icon: 'none' })
      return
    }
    if (!wx.getStorageSync('CRAB_TOKEN')) {
      wx.navigateTo({ url: '/pages/login/index' })
      return
    }

    this.setData({ submitting: true })
    const payload = {
      bizMode: 'RETAIL',
      source: 'MINIAPP',
      receiverName: address.contact,
      receiverMobile: address.mobile,
      receiverAddress: `${address.province || ''}${address.city || ''}${address.district || ''}${address.detail || ''}`,
      items: items.map((item) => ({ skuId: item.skuId, qty: Number(item.quantity) }))
    }

    orderApi
      .create(payload)
      .then((order) => {
        wx.removeStorageSync('CRAB_CHECKOUT_ITEMS')
        return this.pay(order)
      })
      .catch((err) => {
        // 下单失败：保持页面状态，允许用户修改重试
        console.warn('[order create failed]', err)
      })
      .then(() => this.setData({ submitting: false }))
  },

  /** 拉起微信支付（T24）：后端 /order/pay 返回 wx.requestPayment 所需签名参数 */
  pay(order) {
    if (!order || !order.orderNo) return Promise.resolve()
    return orderApi
      .pay(order.orderNo, 'WECHAT')
      .then(
        (payParams) =>
          new Promise((resolve) => {
            wx.requestPayment(
              Object.assign({}, payParams, {
                success: () => {
                  wx.redirectTo({ url: '/pages/order/detail?orderNo=' + order.orderNo })
                  resolve()
                },
                fail: () => {
                  // 支付取消/失败：订单进入待支付，由后端延迟队列超时取消
                  wx.redirectTo({ url: '/pages/order/list?status=UNPAID' })
                  resolve()
                }
              })
            )
          })
      )
      .catch(() => {
        wx.redirectTo({ url: '/pages/order/detail?orderNo=' + order.orderNo })
      })
  }
})
