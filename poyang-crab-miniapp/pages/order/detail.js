/**
 * T24 订单详情：状态 / 商品 / 金额 / 收货信息 / 运单 / 操作
 * 后端：GET /order/my/by-no/{orderNo}、/order/my/items?orderId=、/order/my/delivery?orderId=
 */
const { orderApi } = require('../../api/index')
const { money, formatDate, orderStatusText } = require('../../utils/format')

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
    orderNo: '',
    order: null,
    items: [],
    delivery: null,
    loading: true,
    actions: {}
  },

  onLoad(options) {
    this.setData({ orderNo: options.orderNo || '' })
    this.loadOrder()
  },

  loadOrder() {
    if (!this.data.orderNo) {
      this.setData({ loading: false })
      return
    }
    orderApi
      .detailByNo(this.data.orderNo)
      .then((order) => {
        if (!order) {
          this.setData({ loading: false })
          return
        }
        this.setData({
          order: Object.assign({}, order, {
            statusText: orderStatusText(order.orderStatus),
            amountText: money(order.payAmount || order.totalAmount),
            totalAmountText: money(order.totalAmount),
            freightText: money(order.freightAmount || 0),
            discountText: money(order.discountAmount || 0),
            timeText: formatDate(order.createTime)
          }),
          actions: buildActions(order.orderStatus),
          loading: false
        })
        this.loadItems(order.id)
        this.loadDelivery(order.id)
      })
      .catch(() => this.setData({ loading: false }))
  },

  loadItems(orderId) {
    orderApi
      .items(orderId)
      .then((list) =>
        this.setData({
          items: (list || []).map((item) =>
            Object.assign({}, item, {
              priceText: money(item.price),
              amountText: money(item.amount)
            })
          )
        })
      )
      .catch(() => {})
  },

  loadDelivery(orderId) {
    orderApi
      .delivery(orderId)
      .then((delivery) => {
        this.setData({
          delivery: delivery
            ? Object.assign({}, delivery, { shipTimeText: formatDate(delivery.shipTime || delivery.createTime) })
            : null
        })
      })
      .catch(() => {})
  },

  onCopyOrderNo() {
    wx.setClipboardData({ data: this.data.orderNo })
  },

  onPay() {
    orderApi.pay(this.data.orderNo, 'WECHAT').then((payParams) =>
      wx.requestPayment(
        Object.assign({}, payParams, {
          success: () => this.loadOrder(),
          fail: () => wx.showToast({ title: '已取消支付', icon: 'none' })
        })
      )
    )
  },

  onCancel() {
    wx.showModal({
      title: '取消订单',
      content: '确认取消该订单？',
      confirmColor: '#E4393C',
      success: (res) => {
        if (!res.confirm) return
        orderApi.cancel(this.data.orderNo).then(() => this.loadOrder())
      }
    })
  },

  onLogistics() {
    wx.navigateTo({ url: '/pages/logistics/index?orderNo=' + this.data.orderNo })
  },

  onConfirm() {
    wx.showModal({
      title: '确认收货',
      content: '请确认湖蟹鲜活完好后再确认收货。',
      success: (res) => {
        if (!res.confirm) return
        orderApi.confirm(this.data.orderNo).then(() => this.loadOrder())
      }
    })
  },

  onReview() {
    wx.navigateTo({ url: '/pages/review/index?orderNo=' + this.data.orderNo })
  }
})
