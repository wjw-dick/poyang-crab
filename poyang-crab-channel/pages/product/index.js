/**
 * T26 渠道专属价商品列表：批发价（SKU 维度）+ 加入报单草稿
 */
const { channelApi } = require('../../api/index')
const { money, splitPrice } = require('../../utils/format')

Page({
  data: {
    keyword: '',
    products: [],
    expandedId: null,
    loading: false,
    draftCount: 0
  },

  onShow() {
    this.setData({ draftCount: (getApp().globalData.reportDraft || []).length })
    this.loadProducts()
  },

  onPullDownRefresh() {
    this.loadProducts()
    wx.stopPullDownRefresh()
  },

  loadProducts() {
    this.setData({ loading: true })
    channelApi
      .products(this.data.keyword)
      .then((list) => {
        const products = (list || []).map((item) =>
          Object.assign({}, item, {
            skus: (item.skus || []).map((sku) =>
              Object.assign({}, sku, {
                channelPriceText: money(sku.channelPrice),
                retailPriceText: money(sku.retailPrice),
                // 渠道价与零售价差额，便于渠道商直观看到毛利空间
                benefit: money(Number(sku.retailPrice || 0) - Number(sku.channelPrice || 0))
              })
            )
          })
        )
        this.setData({ products })
      })
      .catch(() => {})
      .then(() => this.setData({ loading: false }))
  },

  onSearchInput(e) {
    this.setData({ keyword: e.detail.value })
  },

  onSearch() {
    this.loadProducts()
  },

  onToggle(e) {
    const id = e.currentTarget.dataset.id
    this.setData({ expandedId: this.data.expandedId === id ? null : id })
  },

  /** 加入报单草稿（本地暂存，报单页再提交） */
  onAddDraft(e) {
    const { productId, skuid, name, price, image } = e.currentTarget.dataset
    const app = getApp()
    const draft = (app.globalData.reportDraft || []).slice()
    const exist = draft.find((item) => item.skuId === skuid)
    if (exist) {
      exist.qty += 1
    } else {
      draft.push({
        productId: Number(productId),
        skuId: Number(skuid),
        skuName: name,
        channelPrice: Number(price),
        image,
        qty: 1
      })
    }
    app.saveReportDraft(draft)
    this.setData({ draftCount: draft.length })
    wx.showToast({ title: '已加入报单', icon: 'none' })
  },

  onGoReport() {
    wx.switchTab({ url: '/pages/report/index' })
  }
})
