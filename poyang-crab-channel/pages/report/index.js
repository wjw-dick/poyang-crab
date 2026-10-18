/**
 * T25 渠道报单：草稿（渠道价 + 数量）→ 提交等待后台审核 → 我的报单记录
 * 后端：POST /channel/biz/report/submit（body 为 [{skuId, qty}]），起订量由 sys_config 控制。
 */
const { channelApi } = require('../../api/index')
const { money, formatDate, textOf, AUDIT_STATUS_TEXT } = require('../../utils/format')

Page({
  data: {
    draft: [],
    totalQty: 0,
    totalAmount: '0.00',
    minOrderQty: 10,
    submitting: false,
    reports: [],
    page: 1,
    size: 10,
    loading: false,
    finished: false,
    tab: 'draft'
  },

  onShow() {
    this.setData({ draft: (getApp().globalData.reportDraft || []).slice() }, () => this.calc())
    if (this.data.tab === 'history') {
      this.loadReports(true)
    }
    this.loadMinOrderQty()
  },

  onPullDownRefresh() {
    if (this.data.tab === 'history') this.loadReports(true)
    wx.stopPullDownRefresh()
  },

  onReachBottom() {
    if (this.data.tab === 'history') this.loadReports(false)
  },

  onTabTap(e) {
    const tab = e.currentTarget.dataset.tab
    this.setData({ tab })
    if (tab === 'history') this.loadReports(true)
  },

  loadMinOrderQty() {
    channelApi
      .overview()
      .then((data) => this.setData({ minOrderQty: (data && data.minOrderQty) || 10 }))
      .catch(() => {})
  },

  calc() {
    const draft = this.data.draft
    const totalQty = draft.reduce((sum, item) => sum + Number(item.qty || 0), 0)
    const totalAmount = draft.reduce((sum, item) => sum + Number(item.channelPrice || 0) * Number(item.qty || 0), 0)
    this.setData({ totalQty, totalAmount: money(totalAmount) })
  },

  onQuantityChange(e) {
    const { skuid, delta } = e.currentTarget.dataset
    const draft = this.data.draft.map((item) =>
      item.skuId === Number(skuid) ? Object.assign({}, item, { qty: Math.max(1, Number(item.qty) + Number(delta)) }) : item
    )
    this.setData({ draft }, () => this.calc())
  },

  onQuantityInput(e) {
    const skuid = e.currentTarget.dataset.skuid
    const value = Math.max(1, Number(e.detail.value) || 1)
    const draft = this.data.draft.map((item) => (item.skuId === Number(skuid) ? Object.assign({}, item, { qty: value }) : item))
    this.setData({ draft }, () => this.calc())
  },

  onRemove(e) {
    const draft = this.data.draft.filter((item) => item.skuId !== Number(e.currentTarget.dataset.skuid))
    this.setData({ draft }, () => this.calc())
    getApp().saveReportDraft(draft)
  },

  onClear() {
    wx.showModal({
      title: '清空报单',
      content: '确认清空当前报单草稿？',
      confirmColor: '#E4393C',
      success: (res) => {
        if (!res.confirm) return
        getApp().saveReportDraft([])
        this.setData({ draft: [], totalQty: 0, totalAmount: '0.00' })
      }
    })
  },

  onSubmit() {
    const draft = this.data.draft
    if (!draft.length) {
      wx.showToast({ title: '请先选择报单商品', icon: 'none' })
      return
    }
    if (this.data.totalQty < this.data.minOrderQty) {
      wx.showToast({ title: '批发起订量为 ' + this.data.minOrderQty + ' 件', icon: 'none' })
      return
    }
    if (this.data.submitting) return
    this.setData({ submitting: true })

    wx.showModal({
      title: '提交报单',
      content: '共 ' + this.data.totalQty + ' 件，金额 ¥' + this.data.totalAmount + '，提交后等待平台审核。',
      success: (res) => {
        if (!res.confirm) {
          this.setData({ submitting: false })
          return
        }
        channelApi
          .submitReport(draft.map((item) => ({ skuId: item.skuId, qty: Number(item.qty) })))
          .then((report) => {
            getApp().saveReportDraft([])
            this.setData({ draft: [], totalQty: 0, totalAmount: '0.00', tab: 'history' })
            wx.showToast({ title: '报单成功，待审核', icon: 'success' })
            this.loadReports(true)
            console.warn('[report submitted]', report && report.reportNo)
          })
          .catch(() => {})
          .then(() => this.setData({ submitting: false }))
      }
    })
  },

  loadReports(reset) {
    if (this.data.loading || (!reset && this.data.finished)) return
    const page = reset ? 1 : this.data.page
    this.setData({ loading: true })
    channelApi
      .reportPage({ current: page, size: this.data.size })
      .then((result) => {
        const records = ((result && result.records) || []).map((item) =>
          Object.assign({}, item, {
            auditStatusText: textOf(AUDIT_STATUS_TEXT, item.auditStatus),
            amountText: money(item.totalAmount),
            timeText: formatDate(item.createTime)
          })
        )
        this.setData({
          reports: reset ? records : this.data.reports.concat(records),
          page: page + 1,
          finished: records.length < this.data.size
        })
      })
      .catch(() => {})
      .then(() => this.setData({ loading: false }))
  },

  onGoProduct() {
    wx.switchTab({ url: '/pages/product/index' })
  }
})
