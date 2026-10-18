/**
 * T24 收货评价：评分 + 存活率 + 文字 + 图片
 * 图片走 sys_file 上传（T13），此处直接调 /system/file/upload 取得 URL 再提交评价
 */
const { reviewApi, orderApi } = require('../../api/index')
const { request } = require('../../utils/request')
const { BASE_URL } = require('../../config/index')

Page({
  data: {
    orderNo: '',
    order: null,
    productId: null,
    skuId: null,
    score: 5,
    survivalRate: 5,
    content: '',
    images: [],
    submitting: false
  },

  onLoad(options) {
    const orderNo = options.orderNo || ''
    this.setData({ orderNo })
    this.loadOrder(orderNo)
  },

  loadOrder(orderNo) {
    if (!orderNo) return
    orderApi
      .detailByNo(orderNo)
      .then((order) => {
        if (!order) return
        this.setData({ order })
        return orderApi.items(order.id).then((list) => {
          const first = (list || [])[0]
          if (first) {
            this.setData({ productId: first.productId, skuId: first.skuId })
          }
        })
      })
      .catch(() => {})
  },

  onScoreTap(e) {
    this.setData({ score: Number(e.currentTarget.dataset.score) })
  },

  onSurvivalTap(e) {
    this.setData({ survivalRate: Number(e.currentTarget.dataset.rate) })
  },

  onContentInput(e) {
    this.setData({ content: e.detail.value })
  },

  /** 选择并上传图片（最多 6 张） */
  onChooseImage() {
    const remain = 6 - this.data.images.length
    if (remain <= 0) {
      wx.showToast({ title: '最多 6 张', icon: 'none' })
      return
    }
    wx.chooseMedia({
      count: remain,
      mediaType: ['image'],
      sizeType: ['compressed'],
      success: (res) => {
        res.tempFiles.forEach((file) => this.uploadImage(file.tempFilePath))
      }
    })
  },

  uploadImage(filePath) {
    wx.showLoading({ title: '上传中', mask: true })
    wx.uploadFile({
      url: BASE_URL + '/system/file/upload',
      filePath,
      name: 'file',
      header: { Authorization: 'Bearer ' + wx.getStorageSync('CRAB_TOKEN') },
      success: (res) => {
        try {
          const body = JSON.parse(res.data)
          if (body.code === 200) {
            this.setData({ images: this.data.images.concat([body.data.url || body.data.fileUrl || body.data]) })
          } else {
            wx.showToast({ title: body.message || '上传失败', icon: 'none' })
          }
        } catch (e) {
          wx.showToast({ title: '上传失败', icon: 'none' })
        }
      },
      fail: () => wx.showToast({ title: '上传失败', icon: 'none' }),
      complete: () => wx.hideLoading()
    })
  },

  onPreviewImage(e) {
    wx.previewImage({ current: e.currentTarget.dataset.url, urls: this.data.images })
  },

  onRemoveImage(e) {
    const index = e.currentTarget.dataset.index
    const images = this.data.images.slice()
    images.splice(index, 1)
    this.setData({ images })
  },

  onSubmit() {
    if (!this.data.content.trim()) {
      wx.showToast({ title: '请填写评价内容', icon: 'none' })
      return
    }
    if (this.data.submitting) return
    this.setData({ submitting: true })

    const payload = {
      orderNo: this.data.orderNo,
      productId: this.data.productId,
      skuId: this.data.skuId,
      score: this.data.score,
      survivalRate: this.data.survivalRate,
      content: this.data.content,
      images: this.data.images.join(','),
      isShow: 1
    }

    reviewApi
      .create(payload)
      .then(() => {
        wx.showToast({ title: '评价成功', icon: 'success' })
        setTimeout(() => wx.navigateBack(), 800)
      })
      .catch((err) => {
        // 后端 SensitiveWordService 命中敏感词会返回业务错误，此处保留内容供修改
        console.warn('[review failed]', err)
      })
      .then(() => this.setData({ submitting: false }))
  }
})
