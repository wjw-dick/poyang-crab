/**
 * T23 会员中心：积分 / 储值 / 卡券 / 历史订单 / 收货地址管理
 * pages/member/index?tab=address&select=1 可作为确认订单页的地址选择器
 */
const { memberApi } = require('../../api/index')
const { money, formatDate } = require('../../utils/format')

Page({
  data: {
    tab: 'center',
    selectMode: false,
    profile: null,
    addresses: [],
    points: [],
    balances: [],
    coupons: [],
    recentOrders: [],
    orderEntries: [
      { status: 'UNPAID', label: '待支付' },
      { status: 'PAID', label: '待发货' },
      { status: 'SHIPPED', label: '待收货' },
      { status: 'COMPLETED', label: '已完成' }
    ]
  },

  onLoad(options) {
    if (options.tab === 'address') {
      this.setData({ tab: 'address', selectMode: options.select === '1' }, () => this.loadAddresses())
    } else {
      this.loadProfile()
      this.loadPoints()
      this.loadBalances()
      this.loadCoupons()
    }
  },

  onShow() {
    if (this.data.tab === 'address') {
      this.loadAddresses()
    }
  },

  onTabChange(e) {
    const tab = e.currentTarget.dataset.tab
    this.setData({ tab })
    if (tab === 'address') this.loadAddresses()
    if (tab === 'center') this.loadProfile()
  },

  loadProfile() {
    // 后端 /member/profile 直接返回当前登录会员（已脱敏 openid/unionid）
    memberApi
      .profile()
      .then((member) => this.setData({ profile: member || null }))
      .catch(() => {})
  },

  loadAddresses() {
    memberApi
      .addresses()
      .then((list) => this.setData({ addresses: list || [] }))
      .catch(() => {})
  },

  loadPoints() {
    memberApi
      .pointLogs({ current: 1, size: 5 })
      .then((res) => this.setData({ points: ((res && res.records) || []).map((item) => Object.assign({}, item, { timeText: formatDate(item.createTime) })) }))
      .catch(() => {})
  },

  loadBalances() {
    memberApi
      .balanceLogs({ current: 1, size: 5 })
      .then((res) =>
        this.setData({
          balances: ((res && res.records) || []).map((item) =>
            Object.assign({}, item, {
              timeText: formatDate(item.createTime),
              amountText: money(item.changeAmount || 0)
            })
          )
        })
      )
      .catch(() => {})
  },

  loadCoupons() {
    memberApi
      .coupons({ current: 1, size: 5 })
      .then((res) => this.setData({ coupons: (res && res.records) || [] }))
      .catch(() => {})
  },

  onOrderEntry(e) {
    wx.navigateTo({ url: '/pages/order/list?status=' + e.currentTarget.dataset.status })
  },

  onAllOrders() {
    wx.switchTab({ url: '/pages/order/list' })
  },

  /** 地址选择模式：点选后回填确认订单页 */
  onAddressTap(e) {
    const address = this.data.addresses.find((item) => item.id === e.currentTarget.dataset.id)
    if (!this.data.selectMode || !address) {
      this.editAddress(address)
      return
    }
    const pages = getCurrentPages()
    const prev = pages[pages.length - 2]
    if (prev && prev.setData) {
      prev.setData({ address })
    }
    wx.navigateBack()
  },

  onAddAddress() {
    this.editAddress(null)
  },

  editAddress(address) {
    // TODO(T23) 地址编辑弹层：骨架期以输入提示占位，正式版需完整省市区选择器
    wx.showModal({
      title: address ? '编辑地址' : '新增地址',
      editable: true,
      placeholderText: '收货人 手机号 省市区详细地址',
      success: (res) => {
        if (!res.confirm || !res.content) return
        const parts = res.content.split(/\s+/)
        const payload = Object.assign({}, address || {}, {
          contact: parts[0] || '',
          mobile: parts[1] || '',
          detail: parts.slice(2).join(' ') || '',
          isDefault: (address && address.isDefault) || (this.data.addresses.length ? 0 : 1)
        })
        memberApi.addressSave(payload).then(() => this.loadAddresses())
      }
    })
  },

  onDeleteAddress(e) {
    const id = e.currentTarget.dataset.id
    wx.showModal({
      title: '删除地址',
      content: '确认删除该收货地址？',
      confirmColor: '#E4393C',
      success: (res) => {
        if (!res.confirm) return
        memberApi.addressDelete(id).then(() => this.loadAddresses())
      }
    })
  },

  onLogin() {
    wx.navigateTo({ url: '/pages/login/index' })
  },

  onLogout() {
    wx.showModal({
      title: '退出登录',
      content: '确认退出当前账号？',
      success: (res) => {
        if (!res.confirm) return
        getApp().logout()
        this.setData({ profile: null })
        wx.showToast({ title: '已退出', icon: 'none' })
      }
    })
  },

  onContactService() {
    wx.showToast({ title: '客服功能待接入', icon: 'none' })
  }
})
