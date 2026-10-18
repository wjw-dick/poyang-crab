import { defineStore } from 'pinia'
import type { Router, RouteRecordRaw } from 'vue-router'
import { authApi } from '@/api'
import { clearToken, getToken, setToken } from '@/api/request'

interface UserState {
  token: string
  username: string
  nickname: string
  roleType: string
  perms: string[]
  /** 权限信息是否已就绪（刷新页面后需先调 /auth/profile 回填） */
  profileLoaded: boolean
  routesLoaded: boolean
}

export const useUserStore = defineStore('user', {
  state: (): UserState => ({
    token: getToken(),
    username: '',
    nickname: '',
    roleType: '',
    perms: [],
    profileLoaded: false,
    routesLoaded: false
  }),
  getters: {
    /** 超管（PRO.md 6.2）：除审计日志只读外全量 CRUD */
    isSuperAdmin: (state) => state.roleType === 'SUPER_ADMIN' || state.perms.includes('*:*:*'),
    /** 权限判定：超管直通 */
    hasPerm: (state) => (perm?: string) => {
      if (!perm) return true
      if (state.perms.includes('*:*:*')) return true
      return state.perms.includes(perm)
    }
  },
  actions: {
    async login(payload: { username: string; password: string }) {
      const data = await authApi.login(payload)
      this.token = data.token
      this.username = data.username
      this.nickname = (data as { nickname?: string }).nickname || ''
      this.roleType = data.roleType
      this.perms = data.perms || []
      this.profileLoaded = true
      // 换账号登录时必须重新注册路由，否则会沿用上一个账号的路由表
      this.routesLoaded = false
      setToken(data.token)
    },
    /**
     * 刷新页面后 pinia 状态会重置为初始值（只有 token 从 localStorage 恢复），
     * 此时必须回后端取一次权限标识；否则 registerRoutes 会按空权限过滤，
     * 导致所有动态路由丢失 —— 表现就是「侧边菜单全空 / 点任何菜单都被兜底路由弹回看板」。
     */
    async loadProfile() {
      const data = (await authApi.profile()) as {
        username?: string
        nickname?: string
        roleType?: string
        perms?: string[]
      } | null
      if (!data) {
        throw new Error('未获取到登录信息')
      }
      this.username = data.username || ''
      this.nickname = data.nickname || ''
      this.roleType = data.roleType || ''
      this.perms = data.perms || []
      this.profileLoaded = true
    },
    logout() {
      this.token = ''
      this.username = ''
      this.nickname = ''
      this.roleType = ''
      this.perms = []
      this.profileLoaded = false
      this.routesLoaded = false
      clearToken()
    },
    /** 按权限过滤后动态注册路由（接入 vue-pure-admin 后可换成后端下发菜单） */
    registerRoutes(router: Router, routes: RouteRecordRaw[], fallback?: RouteRecordRaw) {
      if (this.routesLoaded) return
      routes.forEach((route) => {
        const children = (route.children || []).filter((child) => this.hasPerm(child.meta?.perm as string))
        if (route.children && children.length === 0) {
          return
        }
        router.addRoute({ ...route, children })
      })
      // 兜底路由最后加，确保它的重定向目标此时已存在
      if (fallback) {
        router.addRoute(fallback)
      }
      this.routesLoaded = true
    }
  }
})
