<template>
  <div class="product-detail">
    <div class="card detail-head">
      <div class="gallery">
        <img class="main-img" :src="mainImage" :alt="product.productName" />
        <div class="thumbs">
          <img
            v-for="(img, index) in images"
            :key="index"
            :src="img"
            :class="{ active: img === mainImage }"
            @click="mainImage = img"
          />
        </div>
      </div>

      <div class="info">
        <h1>{{ lang === 'en-US' && product.productNameEn ? product.productNameEn : product.productName }}</h1>
        <p class="origin">产地：{{ product.origin || '鄱阳湖' }}</p>
        <p class="price">¥ {{ product.retailPrice }} <span>零售价</span></p>
        <p class="wholesale">渠道批发价：登录渠道商端小程序可见</p>

        <!-- 湖蟹规格：公母 / 重量档 / 只数礼盒 -->
        <div class="specs">
          <div v-for="spec in specs" :key="spec.id" class="spec-item">
            <span class="spec-sex">{{ spec.crabSex === 'MALE' ? '公蟹' : spec.crabSex === 'FEMALE' ? '母蟹' : '公母混装' }}</span>
            <span>{{ spec.weightLevel }}</span>
            <span>{{ spec.pieceCount }} 只 / {{ spec.packType === 'GIFT_BOX' ? '礼盒装' : '散装' }}</span>
          </div>
          <div v-if="!specs.length" class="empty">规格待维护</div>
        </div>

        <div class="actions">
          <a class="btn-primary" :href="miniUrl">去小程序下单（全款 · 冷链直达）</a>
          <button class="btn-outline" @click="copyShare">复制分享链接</button>
        </div>
        <p class="tips">现捞鲜活，顺丰冷链；鲜活河蟹损耗以发货端核验为准。</p>
      </div>
    </div>

    <div class="card rich-content" v-html="detailHtml"></div>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useRoute } from 'vue-router'
import { portalApi, type PortalProduct } from '@/api/portal'
import { useI18n } from '@/composables/useI18n'
import { useSeo } from '@/composables/useSeo'

/**
 * T23 H5 商品分享页 / T16 C 端下单入口：与小程序同源数据（/portal/product/{id}）
 */
const route = useRoute()
const { lang } = useI18n()
const product = ref<PortalProduct>({} as PortalProduct)
const specs = ref<Array<Record<string, any>>>([])
const mainImage = ref('')

const images = computed(() => {
  try {
    const parsed = product.value.images ? JSON.parse(String(product.value.images)) : []
    return Array.isArray(parsed) && parsed.length ? parsed : [product.value.mainImage].filter(Boolean)
  } catch (error) {
    return [product.value.mainImage].filter(Boolean)
  }
})

const detailHtml = computed(() =>
  lang.value === 'en-US' && product.value.detailHtmlEn ? product.value.detailHtmlEn : product.value.detailHtml || '<p>详情待补充</p>'
)

const miniUrl = computed(() => `https://xiegongzhu.com/miniapp/pages/product/detail?id=${route.params.id}`)

useSeo(() => ({
  title: product.value.seoTitle || product.value.productName,
  keywords: product.value.seoKeywords,
  desc: product.value.seoDesc,
  image: product.value.mainImage
}))

const copyShare = async () => {
  await navigator.clipboard?.writeText(window.location.href)
}

onMounted(async () => {
  const data = await portalApi.productDetail(String(route.params.id))
  product.value = data.product as never
  specs.value = data.specs || []
  mainImage.value = product.value.mainImage || ''
})
</script>

<style scoped>
.detail-head {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 24px;
}
@media (max-width: 860px) {
  .detail-head {
    grid-template-columns: 1fr;
  }
}
.main-img {
  width: 100%;
  border-radius: 12px;
  aspect-ratio: 1 / 1;
  object-fit: cover;
  background: #eef2f7;
}
.thumbs {
  display: flex;
  gap: 8px;
  margin-top: 10px;
}
.thumbs img {
  width: 60px;
  height: 60px;
  object-fit: cover;
  border-radius: 6px;
  border: 2px solid transparent;
  cursor: pointer;
}
.thumbs img.active {
  border-color: #e11d48;
}
.info h1 {
  margin: 0 0 8px;
  font-size: 22px;
}
.origin {
  color: #94a3b8;
  font-size: 13px;
}
.price {
  font-size: 20px;
}
.price span {
  font-size: 12px;
  color: #94a3b8;
  margin-left: 6px;
}
.wholesale {
  color: #94a3b8;
  font-size: 12px;
}
.specs {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin: 14px 0;
}
.spec-item {
  display: flex;
  gap: 14px;
  font-size: 13px;
  padding: 8px 12px;
  background: #f8fafc;
  border-radius: 8px;
}
.spec-sex {
  color: #e11d48;
  font-weight: 600;
}
.actions {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
  margin-top: 8px;
}
.tips {
  color: #94a3b8;
  font-size: 12px;
  margin-top: 10px;
}
.rich-content {
  margin-top: 16px;
}
</style>
