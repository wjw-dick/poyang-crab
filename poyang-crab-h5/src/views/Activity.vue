<template>
  <div class="activity">
    <div class="banner">
      <h1>{{ activity.title }}</h1>
      <p>{{ activity.subtitle }}</p>
      <div class="countdown">
        <span v-for="item in countdown" :key="item.label">
          <b>{{ item.value }}</b>{{ item.label }}
        </span>
      </div>
      <a class="btn-primary" :href="miniUrl">立即参与（小程序下单）</a>
    </div>

    <h2 class="section-title">活动商品</h2>
    <div class="grid grid-4">
      <div v-for="product in products" :key="product.id" class="card">
        <img class="thumb" :src="product.mainImage" :alt="product.productName" />
        <h3>{{ product.productName }}</h3>
        <p class="price">¥ {{ product.retailPrice }}</p>
        <router-link class="btn-outline" :to="`/product/${product.id}`">查看详情</router-link>
      </div>
      <div v-if="!products.length" class="empty card">活动商品筹备中</div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { portalApi, type PortalProduct } from '@/api/portal'
import { useSeo } from '@/composables/useSeo'

/**
 * T23 活动落地页：与小程序同源商品数据
 * TODO(T23) 活动配置（标题、时间、商品集合）接入后台活动管理接口
 */
const activity = ref({ title: '螃蟹小公主 · 湖蟹尝鲜季', subtitle: '产地现捞 · 冷链直达 · 直播间同价' })
const products = ref<PortalProduct[]>([])
const countdown = ref([
  { label: '天', value: '00' },
  { label: '时', value: '00' },
  { label: '分', value: '00' }
])
const miniUrl = `https://xiegongzhu.com/miniapp${import.meta.env.VITE_MINIAPP_PATH || '/'}`

useSeo(() => ({ title: activity.value.title, desc: activity.value.subtitle }))

onMounted(async () => {
  products.value = (await portalApi.productList()) as never
})
</script>

<style scoped>
.banner {
  background: linear-gradient(120deg, #0f172a, #1d4ed8);
  color: #fff;
  border-radius: 14px;
  padding: 32px 24px;
  text-align: center;
}
.banner h1 {
  margin: 0 0 8px;
  font-size: 26px;
}
.banner p {
  margin: 0 0 16px;
  color: #cbd5e1;
}
.countdown {
  display: flex;
  gap: 14px;
  justify-content: center;
  margin-bottom: 18px;
}
.countdown b {
  font-size: 22px;
  margin-right: 4px;
}
h3 {
  font-size: 15px;
  margin: 10px 0 6px;
}
</style>
