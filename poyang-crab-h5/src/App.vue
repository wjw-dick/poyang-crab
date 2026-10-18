<template>
  <!-- PC 官网 / H5 分享页 共用外壳：导航由后台菜单配置驱动（T15/T23） -->
  <div class="page">
    <header class="nav">
      <div class="nav-inner">
        <div class="logo">
          <span class="logo-mark">蟹</span>
          <span class="logo-text">螃蟹小公主</span>
        </div>
        <nav class="links">
          <router-link v-for="item in navs" :key="item.id" :to="item.path || '/'">{{ item.menuName }}</router-link>
        </nav>
        <div class="nav-right">
          <a class="btn btn-ghost" :href="miniappUrl">打开小程序下单</a>
          <select v-model="lang" class="lang" @change="switchLang">
            <option value="zh-CN">中文</option>
            <option value="en-US">English</option>
          </select>
        </div>
      </div>
    </header>

    <main class="main">
      <router-view />
    </main>

    <footer class="footer">
      <div class="footer-inner">
        <p>{{ t('footer.brand') }}</p>
        <p>{{ site.icp || 'ICP 备案办理中' }} · {{ site['site.domain'] || 'xiegongzhu.com' }}</p>
        <p class="copyright">{{ site['site.copyright'] || '© 螃蟹小公主' }}</p>
      </div>
    </footer>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { portalApi } from '@/api/portal'
import { useI18n } from '@/composables/useI18n'

const { t, lang, switchLang, loadBundle } = useI18n()
const navs = ref<Array<Record<string, any>>>([])
const site = ref<Record<string, string>>({})
const miniappUrl = `https://xiegongzhu.com/miniapp${import.meta.env.VITE_MINIAPP_PATH || '/'}`

onMounted(async () => {
  await loadBundle()
  navs.value = (await portalApi.nav('PC')) as never
  site.value = await portalApi.site()
})
</script>

<style scoped>
.page {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background: #f7f9fc;
}
.nav {
  background: #0f172a;
  color: #e5e7eb;
  position: sticky;
  top: 0;
  z-index: 20;
}
.nav-inner {
  max-width: 1180px;
  margin: 0 auto;
  display: flex;
  align-items: center;
  gap: 24px;
  padding: 14px 16px;
}
.logo {
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 700;
}
.logo-mark {
  width: 30px;
  height: 30px;
  border-radius: 50%;
  background: #ffd166;
  color: #0f172a;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}
.links {
  display: flex;
  gap: 18px;
  flex: 1;
  font-size: 14px;
}
.links a {
  color: #cbd5e1;
  text-decoration: none;
}
.links a.router-link-active {
  color: #ffd166;
}
.nav-right {
  display: flex;
  align-items: center;
  gap: 10px;
}
.btn {
  border-radius: 6px;
  padding: 8px 14px;
  font-size: 13px;
  text-decoration: none;
}
.btn-ghost {
  border: 1px solid #ffd166;
  color: #ffd166;
}
.lang {
  background: transparent;
  color: #cbd5e1;
  border: 1px solid #334155;
  border-radius: 6px;
  padding: 6px;
}
.main {
  flex: 1;
  max-width: 1180px;
  width: 100%;
  margin: 0 auto;
  padding: 20px 16px 40px;
}
.footer {
  background: #0f172a;
  color: #94a3b8;
  font-size: 13px;
}
.footer-inner {
  max-width: 1180px;
  margin: 0 auto;
  padding: 22px 16px;
}
.footer p {
  margin: 4px 0;
}
.copyright {
  color: #64748b;
}
</style>
