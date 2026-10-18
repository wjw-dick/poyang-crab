import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router'

/**
 * T15 PC 官网 + T16 C 端下单入口 + T23 H5 分享页
 * 使用 history 模式便于 SEO（配合 Nginx try_files 与预渲染）
 */
const routes: RouteRecordRaw[] = [
  { path: '/', name: 'Home', component: () => import('@/views/Home.vue'), meta: { title: '螃蟹小公主 · 鄱阳湖湖蟹' } },
  { path: '/product/:id', name: 'ProductDetail', component: () => import('@/views/ProductDetail.vue'), meta: { title: '商品详情' } },
  { path: '/article/:id', name: 'Article', component: () => import('@/views/Article.vue'), meta: { title: '品牌内容' } },
  { path: '/article/list/:code', name: 'ArticleList', component: () => import('@/views/ArticleList.vue'), meta: { title: '内容列表' } },
  { path: '/recruit', name: 'Recruit', component: () => import('@/views/Recruit.vue'), meta: { title: '招商合作' } },
  { path: '/activity', name: 'Activity', component: () => import('@/views/Activity.vue'), meta: { title: '活动落地页' } },
  { path: '/:pathMatch(.*)*', redirect: '/' }
]

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior: () => ({ top: 0 })
})

router.afterEach((to) => {
  document.title = `${String(to.meta?.title || '')} | 螃蟹小公主 · 鄱阳湖湖蟹`
})

export default router
