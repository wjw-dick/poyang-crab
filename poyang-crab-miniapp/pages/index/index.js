/**
 * T23 商城首页：分类 + 商品列表 + 直播间关联商品 + 文章入口
 */
const { portalApi, liveApi } = require('../../api/index')
const { splitPrice } = require('../../utils/format')

Page({
  data: {
    keyword: '',
    categories: [],
    activeCategoryId: null,
    products: [],
    lives: [],
    articles: [],
    loading: false,
    page: 1,
    size: 10,
    finished: false
  },

  onLoad() {
    this.loadCategories()
    this.loadProducts(true)
    this.loadLives()
    this.loadArticles()
  },

  onPullDownRefresh() {
    this.loadProducts(true)
    this.loadLives()
    wx.stopPullDownRefresh()
  },

  onReachBottom() {
    this.loadProducts(false)
  },

  loadCategories() {
    portalApi
      .categories()
      .then((list) => this.setData({ categories: list || [] }))
      .catch(() => {})
  },

  /** 商品列表：${categoryId} 由后端过滤 RETAIL/BOTH 在架商品 */
  loadProducts(reset) {
    if (this.data.loading || (!reset && this.data.finished)) return
    const page = reset ? 1 : this.data.page
    this.setData({ loading: true })
    portalApi
      .productList({
        categoryId: this.data.activeCategoryId || '',
        keyword: this.data.keyword,
        current: page,
        size: this.data.size
      })
      .then((list) => {
        const normalized = (list || []).map((item) => ({
          ...item,
          priceParts: splitPrice(item.retailPrice || 0),
          tags: this.buildTags(item)
        }))
        const merged = reset ? normalized : this.data.products.concat(normalized)
        this.setData({
          products: merged,
          page: page + 1,
          finished: normalized.length < this.data.size
        })
      })
      .catch(() => {})
      .then(() => this.setData({ loading: false }))
  },

  /** 湖蟹卖点标签：产地 / 鲜活 / 礼盒 */
  buildTags(item) {
    const tags = []
    if (item.origin) tags.push(item.origin)
    if (item.sellMode === 'BOTH') tags.push('批发可谈')
    return tags.slice(0, 2)
  },

  loadLives() {
    liveApi
      .list()
      .then((res) => this.setData({ lives: (res && res.records) || [] }))
      .catch(() => {})
  },

  loadArticles() {
    portalApi
      .articles('BRAND')
      .then((list) => this.setData({ articles: (list || []).slice(0, 3) }))
      .catch(() => {})
  },

  onSearchInput(e) {
    this.setData({ keyword: e.detail.value })
  },

  onSearch() {
    this.loadProducts(true)
  },

  onCategoryTap(e) {
    const id = e.currentTarget.dataset.id || null
    this.setData({ activeCategoryId: id }, () => this.loadProducts(true))
  },

  onProductTap(e) {
    wx.navigateTo({ url: '/pages/product/detail?id=' + e.currentTarget.dataset.id })
  },

  onLiveTap(e) {
    // TODO(T23) 直播间跳转：订阅消息提醒 + 关联商品浮窗
    wx.showToast({ title: '直播间即将开播', icon: 'none' })
  },

  onArticleTap(e) {
    wx.navigateTo({ url: '/pages/article/index?id=' + e.currentTarget.dataset.id })
  },

  onShareAppMessage() {
    return {
      title: '螃蟹小公主 · 鄱阳湖湖蟹产地直发',
      path: '/pages/index/index'
    }
  }
})
