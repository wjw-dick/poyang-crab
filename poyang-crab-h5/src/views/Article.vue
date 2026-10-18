<template>
  <div class="article">
    <router-link class="back" to="/">← 返回首页</router-link>
    <h1>{{ lang === 'en-US' && article.titleEn ? article.titleEn : article.title }}</h1>
    <p class="meta">发布时间：{{ article.publishTime }} · 浏览 {{ article.viewCount || 0 }}</p>
    <img v-if="article.cover" class="cover" :src="article.cover" :alt="article.title" />
    <div class="card rich-content" v-html="html"></div>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useRoute } from 'vue-router'
import { portalApi } from '@/api/portal'
import { useI18n } from '@/composables/useI18n'
import { useSeo } from '@/composables/useSeo'

/** T15 品牌内容落地页：品牌故事 / 养殖基地 / 捕捞实景（富文本 · 双语） */
const route = useRoute()
const { lang } = useI18n()
const article = ref<Record<string, any>>({})

const html = computed(() =>
  lang.value === 'en-US' && article.value.contentHtmlEn ? article.value.contentHtmlEn : article.value.contentHtml || ''
)

useSeo(() => ({
  title: article.value.seoTitle || article.value.title,
  keywords: article.value.seoKeywords,
  desc: article.value.seoDesc || article.value.summary,
  image: article.value.cover
}))

onMounted(async () => {
  article.value = (await portalApi.article(String(route.params.id))) as never
})
</script>

<style scoped>
.back {
  display: inline-block;
  margin-bottom: 12px;
  color: #64748b;
  font-size: 13px;
  text-decoration: none;
}
h1 {
  font-size: 26px;
  margin: 0 0 8px;
}
.meta {
  color: #94a3b8;
  font-size: 13px;
}
.cover {
  width: 100%;
  border-radius: 12px;
  margin: 12px 0;
}
.rich-content {
  margin-top: 16px;
}
</style>
