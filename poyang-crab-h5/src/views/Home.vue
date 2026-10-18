<template>
  <div class="home">
    <!-- 首屏：IP 定位 + 产地直供 -->
    <section class="hero">
      <div class="hero-text">
        <h1>鄱阳湖原生湖蟹 · 现捞鲜活 · 顺丰冷链</h1>
        <p>
          螃蟹小公主是鄱阳湖产地蟹主，172cm 高挑女士亲自挑蟹，直播间看蟹、挑蟹、下单，
          产地实景 + 冷链履约，建立「鄱阳湖好蟹」的品牌信任。
        </p>
        <div class="hero-actions">
          <a class="btn-primary" :href="routeToMini">立即下单（小程序）</a>
          <router-link class="btn-outline" to="/recruit">渠道批发合作</router-link>
        </div>
      </div>
      <div class="hero-art">
        <img :src="heroImage" alt="鄱阳湖湖蟹产地实景" />
      </div>
    </section>

    <!-- 品牌内容：品牌故事 / 养殖基地 / 捕捞实景（后台 CMS 驱动） -->
    <h2 class="section-title">产地实景</h2>
    <div class="grid grid-3">
      <router-link v-for="item in sceneArticles" :key="item.id" class="card scene-card" :to="`/article/${item.id}`">
        <img class="thumb" :src="item.cover" :alt="item.title" />
        <h3>{{ item.title }}</h3>
        <p>{{ item.summary }}</p>
      </router-link>
      <div v-if="!sceneArticles.length" class="empty card">内容待运营发布（后台 CMS 富文本）</div>
    </div>

    <!-- 商品陈列：C 端下单入口（跳转小程序 / H5） -->
    <h2 class="section-title">在售湖蟹</h2>
    <div class="grid grid-4">
      <div v-for="product in products" :key="product.id" class="card product-card">
        <img class="thumb" :src="product.mainImage" :alt="product.productName" />
        <h3>{{ lang === 'en-US' && product.productNameEn ? product.productNameEn : product.productName }}</h3>
        <p class="origin">产地：{{ product.origin }}</p>
        <p class="price">¥ {{ product.retailPrice }} 起</p>
        <div class="product-actions">
          <router-link class="btn-outline" :to="`/product/${product.id}`">查看详情</router-link>
          <a class="btn-primary" :href="routeToMini">去下单</a>
        </div>
      </div>
      <div v-if="!products.length" class="empty card">商品待上架</div>
    </div>

    <!-- 招商入口 -->
    <h2 class="section-title">分销批发 / 渠道加盟</h2>
    <div class="card recruit">
      <div>
        <h3>成为渠道商</h3>
        <p>经销商 / 代理拿货、团购、加盟、转介绍返佣；渠道专属批发价，佣金比例后台可配置。</p>
      </div>
      <router-link class="btn-primary" to="/recruit">提交合作申请</router-link>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { portalApi, type PortalProduct } from '@/api/portal'
import { useI18n } from '@/composables/useI18n'
import { useSeo } from '@/composables/useSeo'

const { lang } = useI18n()
const products = ref<PortalProduct[]>([])
const sceneArticles = ref<Array<Record<string, any>>>([])
const heroImage = ref('')

useSeo(() => ({
  title: '鄱阳湖湖蟹产地直供 · 鲜活冷链',
  keywords: '鄱阳湖湖蟹,大闸蟹,鲜活湖蟹,产地直供,冷链直发,湖蟹批发,渠道加盟',
  desc: '螃蟹小公主｜鄱阳湖产地蟹主，现捞鲜活，顺丰冷链直达；支持自营零售与渠道批发双模式合作。',
  image: heroImage.value
}))

const routeToMini = computed(() => `https://xiegongzhu.com/miniapp${import.meta.env.VITE_MINIAPP_PATH || '/'}`)

onMounted(async () => {
  const [productList, articles] = await Promise.all([
    portalApi.productList(),
    portalApi.articles(undefined)
  ])
  products.value = productList as never
  sceneArticles.value = (articles as never[]).slice(0, 3)
  heroImage.value = products.value[0]?.mainImage || ''
})
</script>

<style scoped>
.hero {
  display: grid;
  grid-template-columns: 1.1fr 1fr;
  gap: 20px;
  align-items: center;
}
@media (max-width: 860px) {
  .hero {
    grid-template-columns: 1fr;
  }
}
.hero-text h1 {
  font-size: 30px;
  line-height: 1.35;
  margin: 0 0 12px;
}
.hero-text p {
  color: #475569;
  line-height: 1.9;
}
.hero-actions {
  display: flex;
  gap: 12px;
  margin-top: 18px;
  flex-wrap: wrap;
}
.hero-art img {
  width: 100%;
  border-radius: 14px;
}
.scene-card {
  text-decoration: none;
}
.scene-card h3 {
  margin: 12px 0 6px;
  font-size: 16px;
}
.scene-card p {
  margin: 0;
  color: #64748b;
  font-size: 13px;
  line-height: 1.7;
}
.product-card h3 {
  font-size: 15px;
  margin: 12px 0 4px;
}
.origin {
  color: #94a3b8;
  font-size: 12px;
  margin: 0 0 6px;
}
.product-actions {
  display: flex;
  gap: 8px;
  margin-top: 10px;
}
.product-actions .btn-primary,
.product-actions .btn-outline {
  padding: 8px 14px;
  font-size: 13px;
}
.recruit {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  flex-wrap: wrap;
}
.recruit h3 {
  margin: 0 0 6px;
}
.recruit p {
  margin: 0;
  color: #64748b;
  font-size: 13px;
}
</style>
