import { ref } from 'vue'
import { http } from '@/api/request'

/**
 * 全局字典缓存（「系统管理 → 字典管理」维护的那份数据）。
 *
 * 后端 `GET /system/dict/options` 一次返回全部启用字典项：
 *   { "order_status": [ { label: "待支付", value: "UNPAID" }, ... ], ... }
 * 登录后拉一次进内存，列表页 / 表单按 dictType 取中文标签，页面里不再硬编码枚举。
 */
export interface DictOption {
  label: string
  value: string
}

const dicts = ref<Record<string, DictOption[]>>({})
let loading: Promise<void> | null = null

/** 加载字典（带内存缓存；force=true 强制刷新，字典维护页保存后调用） */
export async function loadDicts(force = false): Promise<void> {
  if (!force && Object.keys(dicts.value).length) {
    return
  }
  if (loading) {
    return loading
  }
  loading = http<Record<string, DictOption[]>>({ url: '/system/dict/options' })
    .then((data) => {
      dicts.value = data || {}
    })
    .catch(() => {
      dicts.value = {}
    })
    .finally(() => {
      loading = null
    })
  return loading
}

/** 某类字典的全部选项（表单 / 筛选下拉用） */
export function dictOptions(type?: string): DictOption[] {
  if (!type) {
    return []
  }
  return dicts.value[type] || []
}

/** 字典值 → 中文标签；字典里查不到时原样返回，避免列表出现空白 */
export function dictLabel(type: string | undefined, value: unknown): string {
  if (!type || value === undefined || value === null || value === '') {
    return ''
  }
  const hit = (dicts.value[type] || []).find((item) => String(item.value) === String(value))
  return hit ? hit.label : String(value)
}

export function useDicts() {
  return dicts
}
