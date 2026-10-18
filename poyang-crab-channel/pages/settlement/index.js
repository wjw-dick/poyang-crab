/**
 * T28 对账结算：按周期生成结算单 → 确认 → 待打款；同时提供额度流水视图
 * BACKEND: GET /channel/biz/settlement/create?start=&end=、POST /channel/biz/settlement/{settleNo}/confirm
 */
const { channelApi } = require('../../api/index')
const { money, formatDate, textOf, SETTLEMENT_STATUS_TEXT } = require('../../utils/format')

Page({
  data: {
    tab: 'settlement',
    settlements: [],
    quotaLogs: [],
    page: 1,
    size: 10,
    loading: false,
    finished: false,
    periodStart: '',
    periodEnd: '',
    creating: false
  },

  onLoad(options) {
    if (options.tab === 'quota') {
      this.setData({ tab: 'quota' })
    }
    // 默认统计区间：本月 1 号至今
    const now = new Date()
    const first = new Date(now.getFullYear(), now.getMonth(), 1)
    this.setData({
      periodStart: this.toDate(first),
      periodEnd: this.toDate(now)
    })
    this.reload()
  },

  onPullDownRefresh() {
    this.reload()
    wx.stopPullDownRefresh()
  },

  onReachBottom() {
    if (this.data.tab === 'settlement') this.loadSettlements(false)
  },

  onTabTap(e) {
    const tab = e.currentTarget.dataset.tab
    this.setData({ tab }, () => this.reload())
  },

  reload() {
    if (this.data.tab === 'settlement') {
      this.loadSettlements(true)
    } else {
      this.loadQuotaLogs()
    }
  },

  toDate(date) {
    const pad = (n) => (n < 10 ? '0' + n : '' + n)
    return date.getFullYear() + '-' + pad(date.getMonth() + 1) + '-' + pad(date.getDate())
  },

  onStartChange(e) {
    this.setData({ periodStart: e.detail.value })
  },

  onEndChange(e) {
    this.setData({ periodEnd: e.detail.value })
  },

  onCreate() {
    if (this.data.creating) return
    if (this.data.periodStart > this.data.periodEnd) {
      wx.showToast({ title: '开始日期不能晚于结束日期', icon: 'none' })
      return
    }
    this.setData({ creating: true })
    channelApi
      .createSettlement(this.data.periodStart, this.data.periodEnd)
      .then((settlement) => {
        wx.showToast({ title: '结算单已生成', icon: 'success' })
        console.warn('[settlement created]', settlement && settlement.settleNo)
        this.loadSettlements(true)
      })
      .catch(() => {})
      .then(() => this.setData({ creating: false }))
  },

  onConfirm(e) {
    const settleNo = e.currentTarget.dataset.no
    wx.showModal({
      title: '确认结算单',
      content: '确认后该周期佣金将标记为已结算，操作不可撤销。',
      success: (res) => {
        if (!res.confirm) return
        channelApi.confirmSettlement(settleNo).then(() => {
          wx.showToast({ title: '已确认', icon: 'success' })
          this.loadSettlements(true)
        })
      }
    })
  },

  loadSettlements(reset) {
    if (this.data.loading || (!reset && this.data.finished)) return
    const page = reset ? 1 : this.data.page
    this.setData({ loading: true })
    channelApi
      .settlementPage({ current: page, size: this.data.size })
      .then((result) => {
        const records = ((result && result.records) || []).map((item) =>
          Object.assign({}, item, {
            statusText: textOf(SETTLEMENT_STATUS_TEXT, item.status),
            settleAmountText: money(item.settleAmount),
            commissionAmountText: money(item.commissionAmount),
            periodText: (item.periodStart || '') + ' ~ ' + (item.periodEnd || ''),
            timeText: formatDate(item.createTime)
          })
        )
        this.setData({
          settlements: reset ? records : this.data.settlements.concat(records),
          page: page + 1,
          finished: records.length < this.data.size
        })
      })
      .catch(() => {})
      .then(() => this.setData({ loading: false }))
  },

  loadQuotaLogs() {
    this.setData({ loading: true })
    channelApi
      .quotaLogs()
      .then((list) =>
        this.setData({
          quotaLogs: (list || []).map((item) =>
            Object.assign({}, item, {
              amountText: money(item.amount),
              beforeText: money(item.beforeQuota),
              afterText: money(item.afterQuota),
              timeText: formatDate(item.createTime)
            })
          )
        })
      )
      .catch(() => {})
      .then(() => this.setData({ loading: false }))
  }
})
