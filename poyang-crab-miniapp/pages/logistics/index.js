/**
 * T21/T24 顺丰冷链物流轨迹
 * 后端接口：GET /logistics/track?expressNo=xxx（对应 SfExpressService#queryRoutes）
 */
const request = require('../../utils/request')
const { orderApi } = require('../../api/index')
const { formatDate } = require('../../utils/format')

Page({
  data: {
    orderNo: '',
    expressNo: '',
    delivery: null,
    routes: [],
    loading: true
  },

  onLoad(options) {
    const orderNo = options.orderNo || ''
    this.setData({ orderNo })
    this.loadDelivery()
  },

  loadDelivery() {
    orderApi
      .detailByNo(this.data.orderNo)
      .then((order) => {
        if (!order) {
          this.setData({ loading: false })
          return
        }
        return orderApi.delivery(order.id).then((delivery) => {
          if (!delivery) {
            this.setData({ loading: false })
            return
          }
          this.setData({ delivery, expressNo: delivery.expressNo || '' }, () => this.loadRoutes())
        })
      })
      .catch(() => this.setData({ loading: false }))
  },

  /** 轨迹查询：后端已缓存 trackJson 时优先使用，避免每次都打顺丰接口 */
  loadRoutes() {
    const cached = this.parseTrack(this.data.delivery && this.data.delivery.trackJson)
    if (cached.length) {
      this.setData({ routes: cached, loading: false })
      return
    }
    request
      .get('/logistics/track', { expressNo: this.data.expressNo })
      .then((list) => this.setData({ routes: this.normalize(list), loading: false }))
      .catch(() => {
        this.setData({
          routes: [{ acceptTime: '—', remark: '运单已生成，轨迹同步中' }],
          loading: false
        })
      })
  },

  parseTrack(trackJson) {
    if (!trackJson) return []
    try {
      const parsed = typeof trackJson === 'string' ? JSON.parse(trackJson) : trackJson
      return this.normalize(parsed)
    } catch (e) {
      return []
    }
  },

  normalize(list) {
    return (list || []).map((item) => ({
      acceptTime: item.acceptTime === '—' ? '—' : formatDate(item.acceptTime),
      remark: item.remark || item.opcode || ''
    }))
  },

  onCopyExpressNo() {
    wx.setClipboardData({ data: this.data.expressNo })
  }
})
