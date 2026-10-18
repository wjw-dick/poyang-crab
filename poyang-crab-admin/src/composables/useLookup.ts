import { ref } from 'vue'
import { http } from '@/api/request'

/**
 * 引用表下拉数据源。
 *
 * 后台很多字段存的是别的表的 id（商品分类、渠道商、栏目、商品…），
 * 直接显示 id 对运营不友好。这里统一登记「接口 + 名称字段」：
 *   * 列表页用 lookupLabel(key, row.xxxId) 显示名称
 *   * 表单 / 筛选用 lookupOptions(key) 渲染下拉，直接选名称
 * 首次使用时按 key 拉一次 `/xxx/list` 并缓存；CRUD 后调用 clearLookups() 失效。
 */
export const LOOKUPS = {
  productCategory: { url: '/product/category/list', labelKey: 'categoryName' },
  product: { url: '/product/list', labelKey: 'productName' },
  productSku: { url: '/product/sku/list', labelKey: 'skuName' },
  channel: { url: '/channel/list', labelKey: 'channelName' },
  member: { url: '/member/list', labelKey: 'nickname' },
  cmsCategory: { url: '/cms/category/list', labelKey: 'categoryName' },
  order: { url: '/trade/order/list', labelKey: 'orderNo' },
  role: { url: '/system/role/list', labelKey: 'roleName' }
} as const

export type LookupKey = keyof typeof LOOKUPS

export interface LookupOption {
  label: string
  value: unknown
}

const lookups = ref<Record<string, LookupOption[]>>({})
const pending: Record<string, Promise<LookupOption[]>> = {}

export async function loadLookup(key: LookupKey): Promise<LookupOption[]> {
  if (lookups.value[key]) {
    return lookups.value[key]
  }
  if (!pending[key]) {
    const def = LOOKUPS[key]
    pending[key] = http<Array<Record<string, unknown>>>({ url: def.url })
      .then((rows) => {
        const options: LookupOption[] = (rows || []).map((row) => ({
          label: String(row[def.labelKey] ?? row.id ?? ''),
          value: row.id
        }))
        lookups.value = { ...lookups.value, [key]: options }
        return options
      })
      .catch(() => {
        lookups.value = { ...lookups.value, [key]: [] }
        return []
      })
      .finally(() => {
        delete pending[key]
      })
  }
  return pending[key]
}

/** 批量预加载（列表页渲染前调用，保证首屏就显示名称而不是 id） */
export async function loadLookups(keys: Array<LookupKey | undefined>): Promise<void> {
  const unique = Array.from(new Set(keys.filter(Boolean) as LookupKey[]))
  await Promise.all(unique.map((key) => loadLookup(key)))
}

/** 业务数据变更后调用（新增分类 / 渠道后下拉需要拿到新数据） */
export function clearLookups(): void {
  lookups.value = {}
}

/**
 * 下拉选项
 * @param topLabel 传入时在首位插入「顶级（0）」选项，用于 parentId 这类自关联字段
 */
export function lookupOptions(key?: LookupKey, topLabel?: string): LookupOption[] {
  const options = key ? lookups.value[key] || [] : []
  return topLabel ? [{ label: topLabel, value: 0 }, ...options] : options
}

/** id → 名称；空值 / 0 用 emptyText 兜底（如「顶级」） */
export function lookupLabel(key: LookupKey | undefined, value: unknown, emptyText = ''): string {
  if (!key) {
    return ''
  }
  if (value === undefined || value === null || value === '' || Number(value) === 0) {
    return emptyText
  }
  const hit = (lookups.value[key] || []).find((item) => String(item.value) === String(value))
  return hit ? hit.label : String(value)
}
