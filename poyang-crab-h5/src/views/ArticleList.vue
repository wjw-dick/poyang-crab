<template>
  <div class="article-list">
    <h2 class="section-title">{{ title }}</h2>
    <div class="grid grid-3">
      <router-link v-for="item in list" :key="item.id" class="card" :to="`/article/${item.id}`">
        <img class="thumb" :src="item.cover" :alt="item.title" />
        <h3>{{ item.title }}</h3>
        <p>{{ item.summary }}</p>
      </router-link>
      <div v-if="!list.length" class="empty card">暂无内容</div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useRoute } from 'vue-router'
import { portalApi } from '@/api/portal'
import { useSeo } from '@/composables/useSeo'

/** T15 内容列表（按栏目：brand / base / catch / recruit / notice） */
const route = useRoute()
const list = ref<Array<Record<string, any>>>([])

const NAMES: Record<string, string> = {
  brand: '品牌故事',
  base: '养殖基地',
  catch: '捕捞实景',
  recruit: '招商合作',
  notice: '平台公告'
}
const title = computed(() => NAMES[String(route.params.code)] || '内容')

useSeo(() => ({ title: title.value, desc: `${title.value} · 螃蟹小公主 鄱阳湖湖蟹` }))

onMounted(async () => {
  list.value = (await portalApi.articles(String(route.params.code))) as never
})
</script>

<style scoped>
h3 {
  font-size: 16px;
  margin: 10px 0 6px;
}
p {
  color: #64748b;
  font-size: 13px;
  margin: 0;
}
a {
  text-decoration: none;
}
</style>
