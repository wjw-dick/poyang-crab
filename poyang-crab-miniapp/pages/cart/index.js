/**
 * T23 购物车
 * 说明：服务端 /cart 为骨架接口，本地缓存（CRAB_CART）可独立演示；登录后由 TODO(T24) 做合并。
 */
const { cartApi } = require('../../api/index')
const { splitPrice, money } = require('../../utils/format')

Page({
  data: {
    items: [],
    checkedIds: [],
    totalAmount: '0.00',
    totalParts: splitPrice(0),
    allChecked: false
  },

  onShow() {
    this.loadCart()
  },

  loadCart() {
    // 本地缓存为准（含商品名/图片/价格等展示信息）。
    // TODO(T24) 服务端 cart 表仅存 memberId/skuId/qty/checked，登录后需按 skuId 反查商品补齐展示字段并与本地合并。
    this.applyItems(getApp().globalData.cart || [])
  },

  applyItems(list) {
    const items = (list || []).map((item) => Object.assign({}, item, { checked: true }))
    this.setData({ items, checkedIds: items.map((item) => item.id || item.skuId || item.productId) }, () => this.recalc())
  },

  recalc() {
    const checked = this.data.items.filter((item) => item.checked)
    const total = checked.reduce((sum, item) => sum + Number(item.price || 0) * Number(item.quantity || 0), 0)
    this.setData({
      totalAmount: money(total),
      totalParts: splitPrice(total),
      allChecked: this.data.items.length > 0 && checked.length === this.data.items.length
    })
  },

  onToggle(e) {
    const key = e.currentTarget.dataset.key
    const items = this.data.items.map((item) =>
      (item.id || item.skuId || item.productId) === key ? Object.assign({}, item, { checked: !item.checked }) : item
    )
    this.setData({ items }, () => this.recalc())
  },

  onToggleAll() {
    const next = !this.data.allChecked
    const items = this.data.items.map((item) => Object.assign({}, item, { checked: next }))
    this.setData({ items }, () => this.recalc())
  },

  onQuantityChange(e) {
    const { key, delta } = e.currentTarget.dataset
    const items = this.data.items.map((item) => {
      if ((item.id || item.skuId || item.productId) === key) {
        const minQty = Math.max(1, Number(item.minOrderQty || 1))
        return Object.assign({}, item, { quantity: Math.max(minQty, Number(item.quantity) + Number(delta)) })
      }
      return item
    })
    this.setData({ items }, () => this.recalc())
    this.syncServer()
  },

  onRemove(e) {
    const key = e.currentTarget.dataset.key
    const items = this.data.items.filter((item) => (item.id || item.skuId || item.productId) !== key)
    this.setData({ items }, () => this.recalc())
    this.syncServer()
    wx.showToast({ title: '已移除', icon: 'none' })
  },

  /** 骨架期：服务端失败时仅更新本地缓存 */
  syncServer() {
    const app = getApp()
    app.saveCart(this.data.items)
    const first = this.data.items[0]
    if (first && first.id) {
      cartApi.update(first).catch(() => {})
    }
  },

  onCheckout() {
    const checked = this.data.items.filter((item) => item.checked)
    if (!checked.length) {
      wx.showToast({ title: '请选择商品', icon: 'none' })
      return
    }
    wx.setStorageSync('CRAB_CHECKOUT_ITEMS', checked)
    wx.navigateTo({ url: '/pages/order/confirm?from=cart' })
  },

  onGoShopping() {
    wx.switchTab({ url: '/pages/index/index' })
  }
})
