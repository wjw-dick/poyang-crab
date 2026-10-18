<template>
  <el-container class="app-layout">
    <el-aside :width="collapsed ? '64px' : '220px'" class="app-aside">
      <div class="logo">
        <span v-if="!collapsed">螃蟹小公主</span>
        <span v-else>蟹</span>
      </div>
      <el-menu
        :default-active="$route.path"
        :collapse="collapsed"
        router
        background-color="#1f2937"
        text-color="#cbd5e1"
        active-text-color="#ffd166"
      >
        <template v-for="menu in menus" :key="menu.path">
          <!-- 无分组标题的单子项（如首页/数据看板）：直接渲染为一级菜单，避免出现空标题分组 -->
          <el-menu-item
            v-if="menu.children?.length === 1 && !menu.meta?.title"
            :index="fullPath(menu.path, menu.children[0].path)"
          >
            <el-icon><component :is="menu.children[0].meta?.icon || 'Menu'" /></el-icon>
            <span>{{ menu.children[0].meta?.title }}</span>
          </el-menu-item>
          <el-sub-menu v-else-if="menu.children?.length" :index="menu.path">
            <template #title>
              <el-icon><component :is="menu.meta?.icon || 'Menu'" /></el-icon>
              <span>{{ menu.meta?.title }}</span>
            </template>
            <el-menu-item v-for="child in menu.children" :key="child.path" :index="fullPath(menu.path, child.path)">
              {{ child.meta?.title }}
            </el-menu-item>
          </el-sub-menu>
          <el-menu-item v-else :index="menu.path">
            <el-icon><component :is="menu.meta?.icon || 'Menu'" /></el-icon>
            <span>{{ menu.meta?.title }}</span>
          </el-menu-item>
        </template>
      </el-menu>
    </el-aside>

    <el-container>
      <el-header class="app-header">
        <el-icon class="collapse-btn" @click="collapsed = !collapsed">
          <component :is="collapsed ? 'Expand' : 'Fold'" />
        </el-icon>
        <el-breadcrumb separator="/">
          <el-breadcrumb-item :to="{ path: '/dashboard' }">首页</el-breadcrumb-item>
          <el-breadcrumb-item>{{ $route.meta?.title }}</el-breadcrumb-item>
        </el-breadcrumb>
        <div class="spacer" />
        <el-tag v-if="userStore.isSuperAdmin" type="warning" effect="dark" size="small">超级管理员</el-tag>
        <el-dropdown @command="onCommand">
          <span class="user-name">
            {{ userStore.username || '未登录' }}
            <el-icon><ArrowDown /></el-icon>
          </span>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item command="logout">退出登录</el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </el-header>

      <el-main class="app-main">
        <!--
          注意：这里刻意不使用 <transition mode="out-in"> 包裹路由出口。
          过渡动画依赖 requestAnimationFrame 推进，一旦浏览器标签处于后台/窗口最小化
          （rAF 被暂停），离开动画永远结束不了，新路由就不会挂载 ——
          表现就是「点菜单没反应」。页面切换必须不依赖动画帧。

          :key="route.path" 保证切换菜单时组件重新创建（列表页数据才会重新拉取）。
        -->
        <router-view v-slot="{ Component, route }">
          <component :is="Component" :key="route.path" />
        </router-view>
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup lang="ts">
/**
 * 布局壳（骨架版）。
 * TODO(T07)：正式项目请以 vue-pure-admin 官方模板的 layout 覆盖本文件
 * （PRO.md 6.1 红线：后台禁止手写 layout，需基于 vue-pure-admin/soybean-admin）。
 * 本文件仅保证脚手架可独立运行与联调，菜单数据结构与 official 模板保持一致。
 */
import { computed, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { asyncRoutes } from '@/router'
import { useUserStore } from '@/store/user'

const collapsed = ref(false)
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

const menus = computed(() =>
  asyncRoutes
    .map((menu) => {
      const all = menu.children || []
      const children = all.filter((child) => userStore.hasPerm(child.meta?.perm as string))
      return { menu, all, children }
    })
    // 有子菜单的分组：必须至少有一个有权限的子项，否则整个分组隐藏
    //（否则会退化成"点了却无对应路由"的死菜单，被兜底路由弹回看板）
    .filter(({ menu, all, children }) => (all.length ? children.length > 0 : userStore.hasPerm(menu.meta?.perm as string)))
    .map(({ menu, children }) => ({ ...menu, children }))
)

const fullPath = (parent: string, child: string) => `${parent === '/' ? '' : parent}/${child}`.replace('//', '/')

const onCommand = async (command: string) => {
  if (command === 'logout') {
    userStore.logout()
    await router.push('/login')
  }
}
</script>

<style scoped>
.app-layout {
  height: 100vh;
}
.app-aside {
  background: #1f2937;
  transition: width 0.2s;
  overflow-x: hidden;
}
.logo {
  height: 56px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #ffd166;
  font-weight: 700;
  letter-spacing: 2px;
}
.app-header {
  display: flex;
  align-items: center;
  gap: 16px;
  background: #fff;
  border-bottom: 1px solid #e8ecf3;
}
.spacer {
  flex: 1;
}
.collapse-btn {
  cursor: pointer;
  font-size: 18px;
}
.user-name {
  display: flex;
  align-items: center;
  gap: 4px;
  cursor: pointer;
  color: #333;
}
.app-main {
  background: #f5f7fb;
  padding: 16px;
}
.fade-slide-enter-active,
.fade-slide-leave-active {
  transition: all 0.18s ease;
}
.fade-slide-enter-from,
.fade-slide-leave-to {
  opacity: 0;
  transform: translateY(6px);
}
</style>
