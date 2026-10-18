import { reactive, ref } from 'vue'
import { ElMessage } from 'element-plus'
import type { PageResult } from '@/api/request'

/**
 * 列表页通用逻辑：筛选区（可折叠）+ 斑马纹表格 + 右下分页
 */
export function useTable<T = Record<string, unknown>>(
  loader: (params: Record<string, unknown>) => Promise<PageResult<T>>
) {
  const loading = ref(false)
  const list = ref<T[]>([])
  const total = ref(0)
  const filterVisible = ref(true)

  const query = reactive<Record<string, any>>({
    current: 1,
    size: 10
  })

  const load = async () => {
    loading.value = true
    try {
      const page = await loader({ ...query })
      list.value = (page?.records || []) as T[]
      total.value = page?.total || 0
    } catch (error) {
      list.value = []
      total.value = 0
    } finally {
      loading.value = false
    }
  }

  const search = () => {
    query.current = 1
    load()
  }

  const reset = () => {
    Object.keys(query).forEach((key) => {
      if (key !== 'current' && key !== 'size') {
        query[key] = undefined
      }
    })
    search()
  }

  const onPageChange = (page: number) => {
    query.current = page
    load()
  }

  const onSizeChange = (size: number) => {
    query.size = size
    query.current = 1
    load()
  }

  /** 删除前二次确认（危险操作红色按钮 + 二次确认，PRO.md 6.1） */
  const confirmDelete = async (remover: () => Promise<unknown>, afterLoad = load) => {
    try {
      await remover()
      ElMessage.success('删除成功')
      afterLoad()
    } catch (error) {
      // 错误提示已在 axios 拦截器统一处理
    }
  }

  return {
    loading,
    list,
    total,
    query,
    filterVisible,
    load,
    search,
    reset,
    onPageChange,
    onSizeChange,
    confirmDelete
  }
}
