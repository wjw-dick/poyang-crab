/**
 * T24 订单列表：状态分页 + 待支付去支付 + 已发货查看物流 + 已收货去评价
 * 订单状态字典（sql/03_order.sql）：
 * UNPAID 待支付 / PAID 已支付 / SORTING 分拣中 / PACKED 已打包 / SHIPPED 已发货
 * RECEIVED 已收货 / COMPLETED 已完成 / CANCELLED 已取消 / REFUNDING / REFUNDED
 */
const { orderApi } = require('../../api/index')
const { money, formatDate, orderStatusText } = require('../../utils/format')

const TABS = [
  { value: '', label: '全部' },
  { value: 'UNPAID', label: '待支付' },
  { value: 'PAID', label: '待发货' },
  { value: 'SHIPPED', label: '待收货' },
  { value: 'COMPLETED', label: '已完成' }
]

/** 按订单状态推导可执行操作，避免在 WXML 中写复杂判断 */
function buildActions(status) {
  return {
    canPay: status === 'UNPAID',
    canCancel: status === 'UNPAID',
    canLogistics: status === 'SHIPPED' || status === 'RECEIVED' || status === 'COMPLETED',
    canConfirm: status === 'SHIPPED',
    canReview: status === 'RECEIVED' || status === 'COMPLETED'
  }
}

Page({
  data: {
    tabs: TABS,
    activeStatus: '',
    orders: [],
    page: 1,
    size: 10,
    loading: false,
    finished: false
  },

  onLoad(options) {
    if (options.status) {
      this.setData({ activeStatus: options.status })
    }
    this.loadOrders(true)
  },

  onShow() {
    // 支付返回 / 确认收货后刷新
    if (this.data.orders.length) {
      this.loadOrders(true)
    }
  },

  onPullDownRefresh() {
    this.loadOrders(true)
    wx.stopPullDownRefresh()
  },

  onReachBottom() {
    this.loadOrders(false)
  },

  onTabTap(e) {
    this.setData({ activeStatus: e.currentTarget.dataset.value }, () => this.loadOrders(true))
  },

  loadOrders(reset) {
    if (this.data.loading || (!reset && this.data.finished)) return
    const page = reset ? 1 : this.data.page
    this.setData({ loading: true })
    // 后端 /order/my/page 按登录会员过滤（OrderQueryController）
    orderApi
      .list({ current: page, size: this.data.size, status: this.data.activeStatus || undefined })
      .then((result) => {
        const records = ((result && result.records) || []).map((order) =>
          Object.assign({}, order, buildActions(order.orderStatus), {
            statusText: orderStatusText(order.orderStatus),
            amountText: money(order.payAmount || order.totalAmount),
            timeText: formatDate(order.createTime)
          })
        )
        this.setData({
          orders: reset ? records : this.data.orders.concat(records),
          page: page + 1,
          finished: records.length < this.data.size
        })
      })
      .catch(() => {})
      .then(() => this.setData({ loading: false }))
  },

  onOrderTap(e) {
    wx.navigateTo({ url: '/pages/order/detail?orderNo=' + e.currentTarget.dataset.no })
  },

  onPay(e) {
    const orderNo = e.currentTarget.dataset.no
    orderApi
      .pay(orderNo, 'WECHAT')
      .then((payParams) =>
        wx.requestPayment(
          Object.assign({}, payParams, {
            success: () => this.loadOrders(true),
            fail: () => wx.showToast({ title: '已取消支付', icon: 'none' })
          })
        )
      )
      .catch(() => {})
  },

  onCancel(e) {
    const orderNo = e.currentTarget.dataset.no
    wx.showModal({
      title: '取消订单',
      content: '确认取消该订单？鲜活水产下单后请尽快完成支付。',
      confirmColor: '#E4393C',
      success: (res) => {
        if (!res.confirm) return
        orderApi.cancel(orderNo).then(() => {
          wx.showToast({ title: '已取消', icon: 'none' })
          this.loadOrders(true)
        })
      }
    })
  },

  onLogistics(e) {
    wx.navigateTo({ url: '/pages/logistics/index?orderNo=' + e.currentTarget.dataset.no })
  },

  onConfirm(e) {
    const orderNo = e.currentTarget.dataset.no
    wx.showModal({
      title: '确认收货',
      content: '请确认湖蟹鲜活完好后再确认收货。',
      success: (res) => {
        if (!res.confirm) return
        orderApi.confirm(orderNo).then(() => {
          wx.showToast({ title: '已确认收货', icon: 'success' })
          this.loadOrders(true)
        })
      }
    })
  },

  onReview(e) {
    wx.navigateTo({ url: '/pages/review/index?orderNo=' + e.currentTarget.dataset.no })
  },

  onGoShopping() {
    wx.switchTab({ url: '/pages/index/index' })
  }
})
