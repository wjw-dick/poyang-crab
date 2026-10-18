/**
 * T23 内容详情：品牌故事 / 养殖基地 / 捕捞实景 / 招商（CMS 文章）
 */
const { portalApi } = require('../../api/index')
const { formatDate } = require('../../utils/format')

Page({
  data: {
    article: null,
    loading: true
  },

  onLoad(options) {
    if (!options.id) {
      this.setData({ loading: false })
      return
    }
    portalApi
      .article(options.id)
      .then((article) =>
        this.setData({
          article: article ? Object.assign({}, article, { publishTimeText: formatDate(article.publishTime || article.createTime) }) : null,
          loading: false
        })
      )
      .catch(() => this.setData({ loading: false }))
  },

  onShareAppMessage() {
    return {
      title: (this.data.article && this.data.article.title) || '螃蟹小公主',
      path: '/pages/article/index?id=' + (this.data.article && this.data.article.id)
    }
  }
})
