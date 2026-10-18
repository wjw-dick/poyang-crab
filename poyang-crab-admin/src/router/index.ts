import { createRouter, createWebHashHistory, type RouteRecordRaw } from 'vue-router'
import Layout from '@/layout/index.vue'
import { useUserStore } from '@/store/user'

/**
 * 路由表：与后端 sys_menu 权限标识一一对应（T07 RBAC）
 * 说明：骨架阶段先用静态路由 + perm 过滤；接入 vue-pure-admin 后可改为
 *      `menuApi.routes()` 动态注入（后端已提供 /system/menu/routes）。
 */
export const asyncRoutes: RouteRecordRaw[] = [
  {
    path: '/',
    component: Layout,
    redirect: '/dashboard',
    children: [
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('@/views/dashboard/index.vue'),
        meta: { title: '数据看板', icon: 'DataLine' }
      }
    ]
  },
  {
    path: '/system',
    component: Layout,
    meta: { title: '系统管理', icon: 'Setting' },
    children: [
      { path: 'config', name: 'SysConfig', component: () => import('@/views/system/config/index.vue'), meta: { title: '系统参数', icon: 'Tools', perm: 'system:config:list' } },
      { path: 'i18n', name: 'SysI18n', component: () => import('@/views/system/i18n/index.vue'), meta: { title: '多语言', icon: 'Translate', perm: 'system:i18n:list' } },
      { path: 'dict', name: 'SysDict', component: () => import('@/views/system/dict/index.vue'), meta: { title: '字典管理', icon: 'Collection', perm: 'system:dict:list' } },
      { path: 'menu', name: 'SysMenu', component: () => import('@/views/system/menu/index.vue'), meta: { title: '菜单维护', icon: 'Menu', perm: 'system:menu:list' } },
      { path: 'storage', name: 'SysStorage', component: () => import('@/views/system/storage/index.vue'), meta: { title: '对象存储', icon: 'Cloudy', perm: 'system:storage:list' } },
      { path: 'audit', name: 'SysAudit', component: () => import('@/views/system/audit/index.vue'), meta: { title: '审计日志', icon: 'Document', perm: 'system:audit:list' } }
    ]
  },
  {
    path: '/product',
    component: Layout,
    meta: { title: '商品中心', icon: 'Goods' },
    children: [
      { path: 'list', name: 'ProductList', component: () => import('@/views/product/list/index.vue'), meta: { title: '商品管理', perm: 'product:list' } },
      { path: 'category', name: 'ProductCategory', component: () => import('@/views/product/category/index.vue'), meta: { title: '分类管理', perm: 'product:category:list' } },
      { path: 'stock', name: 'ProductStock', component: () => import('@/views/product/stock/index.vue'), meta: { title: '库存管理', perm: 'product:stock:list' } }
    ]
  },
  {
    path: '/trade',
    component: Layout,
    meta: { title: '交易中心', icon: 'ShoppingCart' },
    children: [
      { path: 'order', name: 'TradeOrder', component: () => import('@/views/trade/order/index.vue'), meta: { title: '订单管理', perm: 'trade:order:list' } },
      { path: 'payment', name: 'TradePayment', component: () => import('@/views/trade/payment/index.vue'), meta: { title: '支付流水', perm: 'trade:payment:list' } },
      { path: 'review', name: 'TradeReview', component: () => import('@/views/trade/review/index.vue'), meta: { title: '评价管理', perm: 'trade:review:list' } }
    ]
  },
  {
    path: '/ship',
    component: Layout,
    meta: { title: '冷链发货端', icon: 'Van' },
    children: [
      { path: 'wait', name: 'ShipWait', component: () => import('@/views/ship/wait/index.vue'), meta: { title: '待发货分拣', perm: 'ship:wait:list' } },
      { path: 'pack', name: 'ShipPack', component: () => import('@/views/ship/pack/index.vue'), meta: { title: '打包核验', perm: 'ship:pack:list' } },
      { path: 'outbound', name: 'ShipOutbound', component: () => import('@/views/ship/outbound/index.vue'), meta: { title: '出库发货', perm: 'ship:outbound:list' } }
    ]
  },
  {
    path: '/channel',
    component: Layout,
    meta: { title: '渠道商管理', icon: 'User' },
    children: [
      { path: 'list', name: 'ChannelList', component: () => import('@/views/channel/list/index.vue'), meta: { title: '渠道档案', perm: 'channel:list' } },
      { path: 'report', name: 'ChannelReport', component: () => import('@/views/channel/report/index.vue'), meta: { title: '报单审核', perm: 'channel:report:list' } },
      { path: 'commission', name: 'ChannelCommission', component: () => import('@/views/channel/commission/index.vue'), meta: { title: '佣金规则', perm: 'channel:commission:list' } },
      { path: 'settlement', name: 'ChannelSettlement', component: () => import('@/views/channel/settlement/index.vue'), meta: { title: '对账结算', perm: 'channel:settlement:list' } }
    ]
  },
  {
    path: '/member',
    component: Layout,
    meta: { title: '会员中心', icon: 'Avatar' },
    children: [
      { path: 'list', name: 'MemberList', component: () => import('@/views/member/list/index.vue'), meta: { title: '会员列表', perm: 'member:list' } },
      { path: 'coupon', name: 'MemberCoupon', component: () => import('@/views/member/coupon/index.vue'), meta: { title: '卡券管理', perm: 'member:coupon:list' } },
      { path: 'assets', name: 'MemberAssets', component: () => import('@/views/member/assets/index.vue'), meta: { title: '积分储值', perm: 'member:assets:list' } }
    ]
  },
  {
    path: '/cms',
    component: Layout,
    meta: { title: '内容管理', icon: 'Document' },
    children: [
      { path: 'article', name: 'CmsArticle', component: () => import('@/views/cms/article/index.vue'), meta: { title: '文章管理', perm: 'cms:article:list' } },
      { path: 'category', name: 'CmsCategory', component: () => import('@/views/cms/category/index.vue'), meta: { title: '栏目管理', perm: 'cms:category:list' } },
      { path: 'apply', name: 'CmsApply', component: () => import('@/views/cms/apply/index.vue'), meta: { title: '渠道申请', perm: 'cms:apply:list' } }
    ]
  }
]

const constantRoutes: RouteRecordRaw[] = [
  { path: '/login', name: 'Login', component: () => import('@/views/login/index.vue'), meta: { title: '登录' } }
]

/**
 * 兜底路由：**必须等动态路由注册完成后再 addRoute**。
 * 若放进 constantRoutes，未登录/未注册时 `/:pathMatch(.*)*` 会与自身重定向目标互相解析，
 * 触发 vue-router 无限递归（RangeError: Maximum call stack size exceeded）。
 */
export const fallbackRoute: RouteRecordRaw = {
  path: '/:pathMatch(.*)*',
  name: 'NotFound',
  redirect: '/dashboard'
}

const router = createRouter({
  history: createWebHashHistory(),
  routes: [...constantRoutes]
})

router.beforeEach(async (to, _from, next) => {
  const userStore = useUserStore()
  document.title = `${to.meta?.title ? to.meta.title + ' · ' : ''}螃蟹小公主 · 后台管理`
  if (to.path === '/login') {
    next()
    return
  }
  if (!userStore.token) {
    next({ path: '/login', query: { redirect: to.fullPath } })
    return
  }
  if (!userStore.routesLoaded) {
    // 刷新页面后 pinia 状态被重置（仅 token 从 localStorage 恢复），
    // 必须先回后端取回权限标识；否则 registerRoutes 会按空权限过滤掉全部动态路由，
    // 表现为侧边菜单全空、点任何菜单都被兜底路由重定向回看板。
    if (!userStore.profileLoaded) {
      try {
        await userStore.loadProfile()
      } catch (error) {
        userStore.logout()
        next({ path: '/login', query: { redirect: to.fullPath } })
        return
      }
    }
    userStore.registerRoutes(router, asyncRoutes, fallbackRoute)
    // 路由表刚变化，需按新表重新解析当前地址（否则 to.matched 仍指向旧表）
    next({ ...to, replace: true })
    return
  }
  next()
})

export default router
