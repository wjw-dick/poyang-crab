/**
 * 批发订单：报单审核通过后生成的正式订单（与 C 端共用订单体系）
 * 后端 /order/my/page 在渠道端登录态下自动按 channel_id 过滤。
 */
const { channelApi } = require('../../api/index')
const { money, formatDate, textOf, ORDER_STATUS_TEXT } = require('../../utils/format')

const TABS = [
  { value: '', label: '全部' },
  { value: 'UNPAID', label: '待支付' },
  { value: 'PAID', label: '待发货' },
  { value: 'SHIPPED', label: '已发货' },
  { value: 'COMPLETED', label: '已完成' }
]

Page({
  data: {
    tabs: TABS,
    activeStatus: '',
    orders: [],
    page: 1,
    size: 10,
    loading: false,
    finished: false,
    expandedNo: null,
    itemsMap: {}
  },

  onLoad() {
    this.loadOrders(true)
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
    channelApi
      .orderPage({ current: page, size: this.data.size, status: this.data.activeStatus || undefined })
      .then((result) => {
        const records = ((result && result.records) || []).map((order) =>
          Object.assign({}, order, {
            statusText: textOf(ORDER_STATUS_TEXT, order.orderStatus),
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

  onToggleDetail(e) {
    const id = e.currentTarget.dataset.id
    if (this.data.expandedNo === id) {
      this.setData({ expandedNo: null })
      return
    }
    this.setData({ expandedNo: id })
    if (!this.data.itemsMap[id]) {
      channelApi
        .orderItems(id)
        .then((list) => {
          const itemsMap = Object.assign({}, this.data.itemsMap)
          itemsMap[id] = (list || []).map((item) =>
            Object.assign({}, item, {
              priceText: money(item.price),
              amountText: money(item.amount)
            })
          )
          this.setData({ itemsMap })
        })
        .catch(() => {})
    }
  },

  onCopyOrderNo(e) {
    wx.setClipboardData({ data: e.currentTarget.dataset.no })
  }
})
