<template>
  <div class="pro-list">
    <!-- 筛选区：可折叠 -->
    <el-card class="filter-card" shadow="never">
      <div class="filter-head">
        <span class="title">{{ title }}</span>
        <div class="head-actions">
          <el-button type="primary" @click="openCreate">新增</el-button>
          <el-button @click="refresh">刷新</el-button>
          <el-button link @click="filterVisible = !filterVisible">
            {{ filterVisible ? '收起筛选' : '展开筛选' }}
            <el-icon><component :is="filterVisible ? 'ArrowUp' : 'ArrowDown'" /></el-icon>
          </el-button>
        </div>
      </div>
      <el-form v-show="filterVisible" inline class="filter-form">
        <el-form-item v-for="field in filterFields" :key="field.prop" :label="field.label">
          <el-select
            v-if="field.type === 'select'"
            v-model="query[field.prop]"
            clearable
            placeholder="全部"
            style="width: 170px"
          >
            <el-option
              v-for="opt in fieldOptions(field)"
              :key="String(opt.value)"
              :label="opt.label"
              :value="opt.value"
            />
          </el-select>
          <el-input v-else v-model="query[field.prop]" clearable placeholder="请输入" style="width: 180px" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="search">查询</el-button>
          <el-button @click="reset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 斑马纹表格；首次加载展示骨架屏，空数据展示空状态插图 -->
    <el-card shadow="never">
      <el-skeleton v-if="loading && !list.length" :rows="6" animated class="list-skeleton" />
      <el-table v-else v-loading="loading" :data="list" stripe border height="calc(100vh - 340px)">
        <el-table-column type="index" label="#" width="56" />
        <el-table-column
          v-for="column in columns"
          :key="column.prop"
          :prop="column.prop"
          :label="column.label"
          :width="column.width"
          show-overflow-tooltip
        >
          <template #default="{ row }">
            <el-image
              v-if="column.type === 'image'"
              :src="row[column.prop]"
              fit="cover"
              style="width: 46px; height: 46px; border-radius: 4px"
              :preview-src-list="row[column.prop] ? [row[column.prop]] : []"
            >
              <!-- 图片 404 / 未上传：兜底占位，避免出现「加载失败」红字 -->
              <template #error>
                <div class="img-fallback"><el-icon><Picture /></el-icon></div>
              </template>
              <template #placeholder>
                <div class="img-fallback"><el-icon><Picture /></el-icon></div>
              </template>
            </el-image>
            <el-tag v-else-if="column.type === 'tag'" size="small">{{ cellText(column, row) }}</el-tag>
            <span v-else-if="column.type === 'money'">¥ {{ row[column.prop] }}</span>
            <span v-else>{{ cellText(column, row) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="openEdit(row)">编辑</el-button>
            <el-button link type="danger" @click="onDelete(row)">删除</el-button>
          </template>
        </el-table-column>

        <template #empty>
          <el-empty description="暂无数据，点击右上角「新增」开始录入" :image-size="110" />
        </template>
      </el-table>

      <!-- 右下分页 -->
      <div class="table-pagination">
        <el-pagination
          background
          layout="total, sizes, prev, pager, next, jumper"
          :total="total"
          :current-page="Number(query.current)"
          :page-size="Number(query.size)"
          :page-sizes="[10, 20, 50, 100]"
          @current-change="onPageChange"
          @size-change="onSizeChange"
        />
      </div>
    </el-card>

    <!-- 新增/编辑弹窗：主按钮右下 + 危险操作二次确认 -->
    <el-dialog v-model="dialogVisible" :title="form.id ? `编辑${title}` : `新增${title}`" :width="dialogWidth" destroy-on-close>
      <div class="form-split">
        <div class="form-split__main">
          <el-form ref="formRef" :model="form" label-width="110px">
            <template v-for="field in mainFields" :key="field.prop">
              <!-- 图片上传：独占整行 -->
              <div v-if="field.type === 'images'" class="form-row-full">
                <el-form-item :label="field.label">
                  <ImageUpload v-model="imageModel[field.prop]" :biz-type="field.bizType || 'product'" />
                </el-form-item>
              </div>
              <!-- 富文本：禁止 textarea -->
              <div v-else-if="field.type === 'editor'" class="form-row-full">
                <el-form-item :label="field.label">
                  <RichEditor v-model="form[field.prop]" :biz-type="field.bizType || 'rich-text'" />
                </el-form-item>
              </div>
              <el-form-item v-else :label="field.label" :prop="field.prop">
                <el-input
                  v-if="!field.type || field.type === 'input'"
                  v-model="form[field.prop]"
                  :placeholder="`请输入${field.label}`"
                />
                <ScanInput
                  v-else-if="field.type === 'scan'"
                  v-model="form[field.prop]"
                  :placeholder="field.placeholder"
                />
                <el-input v-else-if="field.type === 'number'" v-model.number="form[field.prop]" type="number" />
                <el-input v-else-if="field.type === 'textarea'" v-model="form[field.prop]" type="textarea" :rows="3" />
                <el-select
                  v-else-if="field.type === 'select'"
                  v-model="form[field.prop]"
                  filterable
                  clearable
                  style="width: 100%"
                >
                  <el-option
                    v-for="opt in fieldOptions(field)"
                    :key="String(opt.value)"
                    :label="opt.label"
                    :value="opt.value"
                  />
                </el-select>
                <el-switch v-else-if="field.type === 'switch'" v-model="form[field.prop]" :active-value="1" :inactive-value="0" />
                <el-date-picker
                  v-else-if="field.type === 'datetime'"
                  v-model="form[field.prop]"
                  type="datetime"
                  value-format="YYYY-MM-DD HH:mm:ss"
                  style="width: 100%"
                />
                <el-input v-else v-model="form[field.prop]" />
              </el-form-item>
            </template>
          </el-form>
        </div>
        <div class="form-split__side">
          <el-card shadow="never" class="side-card">
            <template #header>辅助信息</template>
            <el-form label-position="top">
              <el-form-item v-for="field in sideFields" :key="field.prop" :label="field.label">
                <el-input v-if="!field.type || field.type === 'input'" v-model="form[field.prop]" />
                <ScanInput
                  v-else-if="field.type === 'scan'"
                  v-model="form[field.prop]"
                  :placeholder="field.placeholder"
                />
                <el-input v-else-if="field.type === 'number'" v-model.number="form[field.prop]" type="number" />
                <el-input v-else-if="field.type === 'textarea'" v-model="form[field.prop]" type="textarea" :rows="3" />
                <el-select
                  v-else-if="field.type === 'select'"
                  v-model="form[field.prop]"
                  filterable
                  clearable
                  style="width: 100%"
                >
                  <el-option
                    v-for="opt in fieldOptions(field)"
                    :key="String(opt.value)"
                    :label="opt.label"
                    :value="opt.value"
                  />
                </el-select>
                <el-switch
                  v-else-if="field.type === 'switch'"
                  v-model="form[field.prop]"
                  :active-value="1"
                  :inactive-value="0"
                />
                <el-input v-else v-model="form[field.prop]" />
              </el-form-item>
            </el-form>
          </el-card>
        </div>
      </div>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="onSave">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
/**
 * 通用列表页（PRO.md 6.1 后台 UI 规范）
 * 筛选区可折叠 + 操作按钮区 + 斑马纹表格 + 右下分页；
 * 弹窗主按钮右下、危险操作红色二次确认、空状态 + 骨架屏。
 *
 * 字段显示三条路：
 *   1) `dict`   —— 取「字典管理」维护的字典项，显示中文（订单状态、销售模式…）
 *   2) `lookup` —— 取引用表（商品分类、渠道商、栏目…），显示名称而不是 id
 *   3) 其它     —— 原样显示
 */
import { computed, reactive, ref, watch } from 'vue'
import { ElMessage, ElMessageBox, type FormInstance } from 'element-plus'
import { Picture } from '@element-plus/icons-vue'
import ImageUpload from '@/components/ImageUpload/index.vue'
import RichEditor from '@/components/RichEditor/index.vue'
import ScanInput from '@/components/ScanInput/index.vue'
import { useTable } from '@/composables/useTable'
import { dictLabel, dictOptions, loadDicts } from '@/composables/useDict'
import { clearLookups, loadLookups, lookupLabel, lookupOptions, type LookupKey } from '@/composables/useLookup'

export interface Column {
  prop: string
  label: string
  width?: number | string
  type?: 'text' | 'tag' | 'image' | 'money' | 'datetime'
  /** 字典类型：按字典项显示中文标签 */
  dict?: string
  /** 引用表：按名称显示（如 categoryId → 分类名称） */
  lookup?: LookupKey
  /** lookup 取值为空 / 0 时显示的文案（如「顶级」） */
  lookupEmpty?: string
  showOverflowTooltip?: boolean
}
export interface Field {
  prop: string
  label: string
  type?: 'input' | 'number' | 'textarea' | 'select' | 'switch' | 'datetime' | 'images' | 'editor' | 'scan'
  options?: Array<{ label: string; value: unknown }>
  /** 字典类型：下拉选项取自字典管理 */
  dict?: string
  /** 引用表：下拉选项取自真实业务表 */
  lookup?: LookupKey
  /** 传文案时在首位插入「该文案（0）」选项，用于 parentId 这类自关联字段 */
  lookupTop?: string
  side?: boolean
  bizType?: string
  placeholder?: string
}
export interface CrudApi {
  page: (params: Record<string, unknown>) => Promise<{ records: unknown[]; total: number }>
  create: (data: Record<string, unknown>) => Promise<unknown>
  update: (data: Record<string, unknown>) => Promise<unknown>
  remove: (id: number | string) => Promise<unknown>
}

const props = withDefaults(
  defineProps<{
    title: string
    api: CrudApi
    columns: Column[]
    fields?: Field[]
    filterFields?: Field[]
    dialogWidth?: string
  }>(),
  { fields: () => [], filterFields: () => [], dialogWidth: '900px' }
)

const { loading, list, total, query, filterVisible, load, search, reset, onPageChange, onSizeChange } = useTable(
  (params) => props.api.page(params) as never
)

const mainFields = computed(() => props.fields.filter((field) => !field.side))
const sideFields = computed(() => props.fields.filter((field) => field.side))

/** 本页用到的引用表（列 + 表单 + 筛选），渲染前预加载，避免先显示 id 再闪成名称 */
const usedLookups = computed<LookupKey[]>(() => {
  const keys = [
    ...props.columns.map((column) => column.lookup),
    ...props.fields.map((field) => field.lookup),
    ...props.filterFields.map((field) => field.lookup)
  ].filter(Boolean) as LookupKey[]
  return Array.from(new Set(keys))
})

/** 下拉选项：字典 > 引用表 > 静态 options */
const fieldOptions = (field: Field) => {
  if (field.dict) {
    return dictOptions(field.dict)
  }
  if (field.lookup) {
    return lookupOptions(field.lookup, field.lookupTop)
  }
  return field.options || []
}

/** 单元格文案：字典中文 / 引用表名称 / 原值 */
const cellText = (column: Column, row: Record<string, unknown>) => {
  if (column.lookup) {
    return lookupLabel(column.lookup, row[column.prop], column.lookupEmpty)
  }
  if (column.dict) {
    return dictLabel(column.dict, row[column.prop])
  }
  return row[column.prop] as string
}

const dialogVisible = ref(false)
const saving = ref(false)
const formRef = ref<FormInstance>()
// 动态表单：字段由 fields 描述，取值类型宽松以兼容 RichEditor(v-model: string) 与 Element 组件
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const form = reactive<Record<string, any>>({})
/** 图片字段双向绑定缓存（数组 <-> JSON 字符串） */
const imageModel = reactive<Record<string, string[]>>({})

const resetForm = () => {
  Object.keys(form).forEach((key) => delete form[key])
  props.fields.forEach((field) => {
    if (field.type === 'images') {
      imageModel[field.prop] = []
    } else if (field.type === 'switch') {
      form[field.prop] = 1
    } else if (field.lookupTop) {
      // 自关联上级字段：不选即 0（顶级）
      form[field.prop] = 0
    } else {
      form[field.prop] = undefined
    }
  })
}

const openCreate = () => {
  resetForm()
  dialogVisible.value = true
}

const openEdit = async (row: Record<string, unknown>) => {
  resetForm()
  Object.assign(form, row)
  props.fields
    .filter((field) => field.type === 'images')
    .forEach((field) => {
      try {
        imageModel[field.prop] = row[field.prop] ? JSON.parse(String(row[field.prop])) : []
      } catch (error) {
        imageModel[field.prop] = row[field.prop] ? [String(row[field.prop])] : []
      }
    })
  dialogVisible.value = true
}

const onSave = async () => {
  saving.value = true
  try {
    const payload: Record<string, unknown> = { ...form }
    props.fields
      .filter((field) => field.type === 'images')
      .forEach((field) => {
        payload[field.prop] = JSON.stringify(imageModel[field.prop] || [])
      })
    if (form.id) {
      await props.api.update(payload)
    } else {
      await props.api.create(payload)
    }
    ElMessage.success('保存成功')
    dialogVisible.value = false
    await reloadAll()
  } finally {
    saving.value = false
  }
}

/** 危险操作：红色按钮 + 二次确认 */
const onDelete = async (row: Record<string, unknown>) => {
  await ElMessageBox.confirm(`确认删除该${props.title}记录？删除后不可恢复。`, '危险操作', {
    type: 'warning',
    confirmButtonText: '确认删除',
    confirmButtonClass: 'el-button--danger'
  })
  await props.api.remove(row.id as number)
  ElMessage.success('删除成功')
  await reloadAll()
}

/** 业务数据变更后：引用表下拉可能已过期，清缓存重新预加载再刷新列表 */
const reloadAll = async () => {
  clearLookups()
  await loadLookups(usedLookups.value)
  load()
}

const refresh = () => load()

watch(
  () => props.api,
  async () => {
    await Promise.all([loadDicts(), loadLookups(usedLookups.value)])
    load()
  },
  { immediate: true }
)
</script>

<style scoped>
.filter-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 10px;
}
.filter-head .title {
  font-weight: 600;
  font-size: 16px;
}
.filter-form {
  row-gap: 8px;
}
.side-card :deep(.el-card__header) {
  padding: 10px 14px;
  font-size: 13px;
  color: #6b7280;
}
/* 骨架屏 */
.list-skeleton {
  padding: 16px;
}
/* 图片加载失败/未上传时的占位（替代 el-image 默认的「加载失败」红字） */
.img-fallback {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 46px;
  height: 46px;
  border-radius: 4px;
  background: #f3f4f6;
  color: #9ca3af;
}
</style>
