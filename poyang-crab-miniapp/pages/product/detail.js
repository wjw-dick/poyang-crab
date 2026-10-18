/**
 * T23 商品详情：湖蟹规格选择（公母 / 重量档 / 只数礼盒）+ SKU 价格 + 加入购物车 / 立即购买
 */
const { portalApi, cartApi, reviewApi } = require('../../api/index')
const { splitPrice, formatDate, genderText } = require('../../utils/format')

Page({
  data: {
    productId: null,
    product: {},
    priceParts: splitPrice(0),
    specs: [],
    skus: [],
    /** 规格分组：公母 -> 重量档 -> 礼盒，由 specs 动态聚合，避免写死 */
    specGroups: [],
    selectedSpec: {},
    currentSku: null,
    quantity: 1,
    reviews: [],
    bannerIndex: 0,
    banners: [],
    loaded: false
  },

  onLoad(options) {
    const id = options.id
    if (!id) {
      wx.showToast({ title: '缺少商品参数', icon: 'none' })
      return
    }
    this.setData({ productId: id })
    this.loadDetail(id)
    this.loadReviews(id)
  },

  loadDetail(id) {
    portalApi
      .productDetail(id)
      .then((data) => {
        const product = data.product || {}
        const specs = data.specs || []
        const skus = data.skus || []
        this.setData({
          product,
          specs,
          skus,
          banners: product.images ? String(product.images).split(',').filter(Boolean) : [product.mainImage],
          specGroups: this.buildGroups(specs),
          priceParts: splitPrice(product.retailPrice || 0),
          loaded: true
        })
      })
      .catch(() => this.setData({ loaded: true }))
  },

  /**
   * 规格分组展示：crabSex（公母）/ weightLevel（重量档）/ packType（礼盒）
   * 湖蟹的关键选购维度，按维度去重后渲染为三排标签。
   */
  buildGroups(specs) {
    const pick = (field, label, formatter) => {
      const map = {}
      specs.forEach((spec) => {
        const value = spec[field]
        if (value === undefined || value === null || value === '') return
        map[value] = formatter ? formatter(spec) : value
      })
      const options = Object.keys(map).map((value) => ({ value, label: map[value] }))
      return options.length ? { field, label, options } : null
    }
    return [
      pick('crabSex', '公母', (spec) => genderText(spec.crabSex)),
      pick('weightLevel', '重量档'),
      pick('packType', '包装')
    ].filter(Boolean)
  },

  loadReviews(productId) {
    reviewApi
      .productReviews(productId)
      .then((res) =>
        this.setData({
          reviews: ((res && res.records) || []).map((item) => ({
            ...item,
            timeText: formatDate(item.createTime)
          }))
        })
      )
      .catch(() => {})
  },

  onSpecTap(e) {
    const { field, value } = e.currentTarget.dataset
    const selectedSpec = Object.assign({}, this.data.selectedSpec, { [field]: value })
    this.setData({ selectedSpec }, () => this.matchSku())
  },

  /** 按已选维度匹配 SKU；后端 SKU 与 specId 关联，此处以规格字段匹配 */
  matchSku() {
    const selected = this.data.selectedSpec
    const matched = this.data.specs.find((spec) =>
      Object.keys(selected).every((field) => spec[field] === selected[field])
    )
    const sku = matched ? this.data.skus.find((item) => item.specId === matched.id) : null
    this.setData({
      currentSku: sku || null,
      priceParts: splitPrice((sku && sku.retailPrice) || this.data.product.retailPrice || 0)
    })
  },

  onQuantityChange(e) {
    const delta = Number(e.currentTarget.dataset.delta)
    const minQty = this.data.product.minOrderQty || 1
    const next = Math.max(minQty, this.data.quantity + delta)
    this.setData({ quantity: next })
  },

  onBannerChange(e) {
    this.setData({ bannerIndex: e.detail.current })
  },

  onPreviewImage() {
    wx.previewImage({
      current: this.data.banners[this.data.bannerIndex],
      urls: this.data.banners
    })
  },

  onCustomerService() {
    // TODO(T23) 接入微信客服消息或后台客服系统
    wx.showToast({ title: '客服功能待接入', icon: 'none' })
  },

  onAddCart() {
    if (!this.checkSpec()) return
    const payload = this.buildCartPayload()
    cartApi
      .add(payload)
      .then(() => {
        this.appendLocalCart(payload)
        wx.showToast({ title: '已加入购物车', icon: 'success' })
      })
      .catch(() => this.appendLocalCart(payload))
  },

  onBuyNow() {
    if (!this.checkSpec()) return
    const item = this.buildCartPayload()
    // 立即购买不经过购物车，参数通过本地缓存透传给确认页
    wx.setStorageSync('CRAB_CHECKOUT_ITEMS', [item])
    wx.navigateTo({ url: '/pages/order/confirm?from=buynow' })
  },

  checkSpec() {
    const groups = this.data.specGroups
    const selected = this.data.selectedSpec
    for (let i = 0; i < groups.length; i += 1) {
      if (!selected[groups[i].field]) {
        wx.showToast({ title: '请选择' + groups[i].label, icon: 'none' })
        return false
      }
    }
    return true
  },

  buildCartPayload() {
    const product = this.data.product
    const sku = this.data.currentSku
    return {
      productId: product.id,
      skuId: sku ? sku.id : null,
      productName: product.productName,
      skuName: sku ? sku.skuName : '',
      image: (sku && sku.image) || product.mainImage,
      price: (sku && sku.retailPrice) || product.retailPrice,
      quantity: this.data.quantity,
      specText: Object.values(this.data.selectedSpec).join(' / ')
    }
  },

  /** 服务端购物车接口为骨架时，用本地缓存兜底，保证可演示 */
  appendLocalCart(payload) {
    const app = getApp()
    const cart = (app.globalData.cart || []).slice()
    const exist = cart.find((item) => item.productId === payload.productId && item.skuId === payload.skuId)
    if (exist) {
      exist.quantity += payload.quantity
    } else {
      cart.push(payload)
    }
    app.saveCart(cart)
  },

  onShareAppMessage() {
    return {
      title: this.data.product.productName || '螃蟹小公主 · 鄱阳湖湖蟹',
      path: '/pages/product/detail?id=' + this.data.productId,
      imageUrl: this.data.product.mainImage
    }
  }
})
