import { watchEffect } from 'vue'

export interface SeoMeta {
  title?: string
  keywords?: string
  desc?: string
  image?: string
}

const setMeta = (name: string, content?: string) => {
  if (!content) return
  let tag = document.querySelector(`meta[name="${name}"]`)
  if (!tag) {
    tag = document.createElement('meta')
    tag.setAttribute('name', name)
    document.head.appendChild(tag)
  }
  tag.setAttribute('content', content)
}

/**
 * T15 双语 SEO：标题 / 关键词 / 描述 / Open Graph
 * 说明：SPA 的首屏 SEO 建议配合预渲染（vite-plugin-prerender）或 SSR；
 *      本 composable 负责路由切换后的 meta 维护与分享卡片信息。
 */
export function useSeo(meta: () => SeoMeta) {
  watchEffect(() => {
    const value = meta()
    if (value.title) document.title = `${value.title} | 螃蟹小公主 · 鄱阳湖湖蟹`
    setMeta('keywords', value.keywords)
    setMeta('description', value.desc)
    setMeta('og:title', value.title)
    setMeta('og:description', value.desc)
    setMeta('og:image', value.image)
    setMeta('og:type', 'website')
  })
}
