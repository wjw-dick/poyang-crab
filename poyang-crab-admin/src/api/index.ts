import { http, type PageResult } from './request'

/** 供页面直接发起接口调用（非 CRUD 的业务接口） */
export { http } from './request'
export type { PageResult } from './request'

/**
 * 通用 CRUD 接口映射：与后端 BaseCrudController 一一对应
 * 覆盖 PRO.md 6.2 红线要求的「超管全量增删改查」
 */
export function createCrudApi<T = Record<string, unknown>>(base: string) {
  return {
    page: (params: Record<string, unknown>) => http<PageResult<T>>({ url: `${base}/page`, params }),
    list: () => http<T[]>({ url: `${base}/list` }),
    detail: (id: number | string) => http<T>({ url: `${base}/${id}` }),
    create: (data: T) => http<number>({ url: base, method: 'post', data }),
    update: (data: T) => http<boolean>({ url: base, method: 'put', data }),
    remove: (id: number | string) => http<boolean>({ url: `${base}/${id}`, method: 'delete' }),
    removeBatch: (ids: Array<number | string>) =>
      http<boolean>({ url: `${base}/batch`, method: 'delete', data: ids })
  }
}

// ---------- T08 系统参数 ----------
export const configApi = {
  grouped: () => http<Record<string, Array<Record<string, unknown>>>>({ url: '/system/config/grouped' }),
  saveGrouped: (data: Record<string, string>) =>
    http<void>({ url: '/system/config/save-grouped', method: 'post', data })
}

// ---------- T12 对象存储 ----------
export const storageApi = {
  drivers: () => http<Array<Record<string, unknown>>>({ url: '/system/storage/drivers' }),
  test: (driver: string, params: Record<string, string>) =>
    http<boolean>({ url: '/system/storage/test', method: 'post', params: { driver }, data: params }),
  apply: (driver: string, params: Record<string, string>) =>
    http<void>({ url: '/system/storage/apply', method: 'post', params: { driver }, data: params })
}

// ---------- 字典（系统管理 → 字典管理） ----------
export const dictApi = {
  ...createCrudApi('/system/dict'),
  /** 全部启用字典项（按 dictType 分组），前端启动时拉一次做本地缓存 */
  options: () => http<Record<string, Array<{ label: string; value: string }>>>({ url: '/system/dict/options' })
}
export const dictItemApi = createCrudApi('/system/dict-item')

// ---------- T10 菜单 ----------
export const menuApi = {
  tree: (platform: string) => http<Array<Record<string, unknown>>>({ url: '/system/menu/tree', params: { platform } }),
  routes: () => http<Array<Record<string, unknown>>>({ url: '/system/menu/routes' }),
  dragSort: (nodes: Array<Record<string, unknown>>) =>
    http<void>({ url: '/system/menu/drag-sort', method: 'post', data: nodes }),
  wxPreview: () => http<string>({ url: '/system/menu/wechat/preview', method: 'post' }),
  wxPublish: () => http<void>({ url: '/system/menu/wechat/publish', method: 'post' })
}

// ---------- T14 审计日志（只读） ----------
export const auditApi = {
  page: (params: Record<string, unknown>) => http<PageResult<Record<string, unknown>>>({ url: '/system/audit/page', params }),
  detail: (id: number) => http<Record<string, unknown>>({ url: `/system/audit/${id}` })
}

// ---------- T13 文件上传 ----------
export const fileApi = {
  upload: (file: File, bizType = 'common') => {
    const form = new FormData()
    form.append('file', file)
    form.append('bizType', bizType)
    return http<{ url: string; objectKey: string }>({
      url: '/system/file/upload',
      method: 'post',
      data: form,
      headers: { 'Content-Type': 'multipart/form-data' }
    })
  }
}

// ---------- 认证 ----------
export const authApi = {
  login: (data: { username: string; password: string }) =>
    http<{ token: string; username: string; roleType: string; perms: string[] }>({
      url: '/auth/login',
      method: 'post',
      data
    }),
  profile: () => http<Record<string, unknown>>({ url: '/auth/profile' }),
  logout: () => http<void>({ url: '/auth/logout', method: 'post' })
}

// ---------- 业务模块（与后端 @RequestMapping 对齐） ----------
export const bizApi = {
  product: createCrudApi('/product'),
  /** 商品分类（商品中心 → 分类管理）；注意与内容栏目 bizApi.category（/cms/category）不是一回事 */
  productCategory: createCrudApi('/product/category'),
  productSpec: createCrudApi('/product/spec'),
  productSku: createCrudApi('/product/sku'),
  stock: createCrudApi('/product/stock'),
  order: createCrudApi('/trade/order'),
  payment: createCrudApi('/trade/payment'),
  delivery: createCrudApi('/trade/delivery'),
  review: createCrudApi('/trade/review'),
  member: createCrudApi('/member'),
  coupon: createCrudApi('/member/coupon'),
  pointLog: createCrudApi('/member/point-log'),
  balanceLog: createCrudApi('/member/balance-log'),
  channel: createCrudApi('/channel'),
  channelReport: createCrudApi('/channel/report'),
  commission: createCrudApi('/channel/commission'),
  settlement: createCrudApi('/channel/settlement'),
  article: createCrudApi('/cms/article'),
  category: createCrudApi('/cms/category'),
  apply: createCrudApi('/cms/apply'),
  menu: createCrudApi('/system/menu'),
  role: createCrudApi('/system/role'),
  user: createCrudApi('/system/user')
}

/** 订单发货（T24 冷链发货端） */
export const shipApi = {
  ship: (orderNo: string, expressNo: string, packCheck: string) =>
    http<void>({ url: '/order/ship', method: 'post', params: { orderNo, expressNo, packCheck } }),
  confirm: (orderNo: string) => http<void>({ url: '/order/confirm', method: 'post', params: { orderNo } })
}
