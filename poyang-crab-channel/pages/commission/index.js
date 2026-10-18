/**
 * T27 佣金 / 转介绍返佣明细
 * 说明：分佣比例由渠道档案或系统默认值决定，落库时已快照 rate（后端 ChannelBizService#calculateCommission）。
 */
const { channelApi } = require('../../api/index')
const { money, formatDate, textOf, SETTLE_STATUS_TEXT, percent } = require('../../utils/format')

const TABS = [
  { value: '', label: '全部' },
  { value: 'PENDING', label: '待结算' },
  { value: 'SETTLED', label: '已结算' }
]

const TYPE_TEXT = {
  DISTRIBUTION: '销售分佣',
  REFERRAL: '转介绍返佣'
}

Page({
  data: {
    tabs: TABS,
    activeStatus: '',
    commissions: [],
    page: 1,
    size: 10,
    loading: false,
    finished: false,
    summary: { pending: '0.00', settled: '0.00', total: '0.00' }
  },

  onLoad() {
    this.loadCommissions(true)
  },

  onPullDownRefresh() {
    this.loadCommissions(true)
    wx.stopPullDownRefresh()
  },

  onReachBottom() {
    this.loadCommissions(false)
  },

  onTabTap(e) {
    this.setData({ activeStatus: e.currentTarget.dataset.value }, () => this.loadCommissions(true))
  },

  loadCommissions(reset) {
    if (this.data.loading || (!reset && this.data.finished)) return
    const page = reset ? 1 : this.data.page
    this.setData({ loading: true })
    channelApi
      .commissionPage({ current: page, size: this.data.size, settleStatus: this.data.activeStatus || undefined })
      .then((result) => {
        const records = ((result && result.records) || []).map((item) =>
          Object.assign({}, item, {
            typeText: TYPE_TEXT[item.commissionType] || item.commissionType,
            statusText: textOf(SETTLE_STATUS_TEXT, item.settleStatus),
            amountText: money(item.amount),
            baseAmountText: money(item.baseAmount),
            rateText: percent(item.rate),
            timeText: formatDate(item.createTime)
          })
        )
        const merged = reset ? records : this.data.commissions.concat(records)
        this.setData({
          commissions: merged,
          page: page + 1,
          finished: records.length < this.data.size
        })
        if (reset) {
          this.calcSummary(merged, result)
        }
      })
      .catch(() => {})
      .then(() => this.setData({ loading: false }))
  },

  /** 汇总以当前加载到的数据估算；精确口径由结算页汇总（T28） */
  calcSummary(records, result) {
    const pending = records.filter((item) => item.settleStatus === 'PENDING').reduce((s, i) => s + Number(i.amount || 0), 0)
    const settled = records.filter((item) => item.settleStatus === 'SETTLED').reduce((s, i) => s + Number(i.amount || 0), 0)
    this.setData({
      summary: {
        pending: money(pending),
        settled: money(settled),
        total: money(pending + settled)
      }
    })
    console.warn('[commission total]', result && result.total)
  },

  onGoSettlement() {
    wx.navigateTo({ url: '/pages/settlement/index' })
  }
})
