<template>
  <div class="dict-page">
    <el-card class="filter-card" shadow="never">
      <div class="filter-head">
        <span class="title">字典管理</span>
        <div class="head-actions">
          <el-tag effect="plain" type="info">
            全站枚举（状态 / 类型 / 等级 / 审核状态 / 支付状态…）统一在这里维护，各页面按「值」显示中文
          </el-tag>
          <el-button @click="refreshAll">刷新</el-button>
        </div>
      </div>
    </el-card>

    <div class="dict-body">
      <!-- 左：字典类型 -->
      <el-card class="type-card" shadow="never">
        <template #header>
          <div class="card-head">
            <span>字典类型</span>
            <el-button link type="primary" @click="openTypeCreate">新增</el-button>
          </div>
        </template>
        <el-input v-model="typeKeyword" placeholder="搜索类型 / 名称" clearable style="margin-bottom: 10px" />
        <div v-loading="typeLoading" class="type-list">
          <div
            v-for="item in typeList"
            :key="item.id"
            class="type-item"
            :class="{ active: item.dictType === activeType }"
            @click="selectType(item)"
          >
            <div class="type-main">
              <div class="type-name">{{ item.dictName }}</div>
              <div class="type-code">{{ item.dictType }}</div>
            </div>
            <div class="type-actions" @click.stop>
              <el-button link type="primary" @click="openTypeEdit(item)">编辑</el-button>
              <el-button link type="danger" @click="onTypeDelete(item)">删除</el-button>
            </div>
          </div>
          <el-empty v-if="!typeLoading && !typeList.length" description="暂无字典类型" :image-size="80" />
        </div>
      </el-card>

      <!-- 右：字典项 -->
      <el-card class="item-card" shadow="never">
        <template #header>
          <div class="card-head">
            <span>
              字典项
              <el-tag v-if="activeType" size="small" effect="plain" style="margin-left: 6px">{{ activeType }}</el-tag>
            </span>
            <el-button type="primary" :disabled="!activeType" @click="openItemCreate">新增字典项</el-button>
          </div>
        </template>

        <el-table v-loading="itemLoading" :data="itemList" stripe border height="calc(100vh - 330px)">
          <el-table-column type="index" label="#" width="56" />
          <el-table-column prop="itemLabel" label="标签（显示中文）" min-width="140" />
          <el-table-column prop="itemValue" label="值（存库）" min-width="140" />
          <el-table-column prop="sort" label="排序" width="80" />
          <el-table-column label="状态" width="90">
            <template #default="{ row }">
              <el-tag :type="row.status === 1 ? 'success' : 'info'" size="small">
                {{ row.status === 1 ? '启用' : '停用' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="remark" label="备注" min-width="140" />
          <el-table-column label="操作" width="160" fixed="right">
            <template #default="{ row }">
              <el-button link type="primary" @click="openItemEdit(row)">编辑</el-button>
              <el-button link type="danger" @click="onItemDelete(row)">删除</el-button>
            </template>
          </el-table-column>
          <template #empty>
            <el-empty :description="activeType ? '该字典下暂无字典项' : '请先在左侧选择字典类型'" :image-size="110" />
          </template>
        </el-table>
      </el-card>
    </div>

    <!-- 字典类型 新增/编辑 -->
    <el-dialog v-model="typeDialog" :title="typeForm.id ? '编辑字典类型' : '新增字典类型'" width="560px" destroy-on-close>
      <el-form ref="typeFormRef" :model="typeForm" label-width="100px">
        <el-form-item label="字典类型" prop="dictType">
          <el-input v-model="typeForm.dictType" placeholder="英文标识，如 order_status；保存后不建议修改" />
        </el-form-item>
        <el-form-item label="字典名称" prop="dictName">
          <el-input v-model="typeForm.dictName" placeholder="中文名称，如 订单状态" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="typeForm.remark" type="textarea" :rows="2" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="typeDialog = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="onTypeSave">确定</el-button>
      </template>
    </el-dialog>

    <!-- 字典项 新增/编辑 -->
    <el-dialog v-model="itemDialog" :title="itemForm.id ? '编辑字典项' : '新增字典项'" width="560px" destroy-on-close>
      <el-form ref="itemFormRef" :model="itemForm" label-width="100px">
        <el-form-item label="所属类型">
          <el-input :model-value="activeType" disabled />
        </el-form-item>
        <el-form-item label="标签">
          <el-input v-model="itemForm.itemLabel" placeholder="页面显示的中文，如 待支付" />
        </el-form-item>
        <el-form-item label="值">
          <el-input v-model="itemForm.itemValue" placeholder="存库的值，如 UNPAID；数字状态用 0 / 1" />
        </el-form-item>
        <el-form-item label="排序">
          <el-input-number v-model="itemForm.sort" :min="0" :max="9999" />
        </el-form-item>
        <el-form-item label="状态">
          <el-switch v-model="itemForm.status" :active-value="1" :inactive-value="0" />
          <span class="tip">停用后该选项不再出现在业务页面（历史数据仍可显示中文）</span>
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="itemForm.remark" type="textarea" :rows="2" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="itemDialog = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="onItemSave">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
/**
 * 字典管理（系统管理 → 字典管理）
 *
 * 左：字典类型（dictType + 中文名）
 * 右：该类型下的字典项（itemLabel 中文 / itemValue 存库值 / 排序 / 状态）
 * 保存后刷新前端字典缓存，业务页面即时显示中文。
 */
import { computed, onMounted, reactive, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { dictApi, dictItemApi } from '@/api'
import { loadDicts } from '@/composables/useDict'

interface DictType {
  id?: number
  dictType: string
  dictName: string
  remark?: string
}

interface DictItem {
  id?: number
  dictType: string
  itemLabel: string
  itemValue: string
  sort: number
  status: number
  remark?: string
}

const typeLoading = ref(false)
const itemLoading = ref(false)
const saving = ref(false)
const types = ref<DictType[]>([])
const typeKeyword = ref('')
const activeType = ref('')

const typeList = computed(() => {
  const keyword = typeKeyword.value.trim().toLowerCase()
  if (!keyword) {
    return types.value
  }
  return types.value.filter(
    (item) => item.dictType.toLowerCase().includes(keyword) || item.dictName.toLowerCase().includes(keyword)
  )
})

const loadTypes = async () => {
  typeLoading.value = true
  try {
    const page = await dictApi.page({ current: 1, size: 500 })
    types.value = ((page?.records || []) as unknown) as DictType[]
    if (!activeType.value && types.value.length) {
      activeType.value = types.value[0].dictType
    }
  } finally {
    typeLoading.value = false
  }
}

const itemList = ref<DictItem[]>([])

const loadItems = async () => {
  if (!activeType.value) {
    itemList.value = []
    return
  }
  itemLoading.value = true
  try {
    const page = await dictItemApi.page({ current: 1, size: 500, dictType: activeType.value })
    itemList.value = ((page?.records || []) as unknown) as DictItem[]
  } finally {
    itemLoading.value = false
  }
}

const selectType = (item: DictType) => {
  activeType.value = item.dictType
  loadItems()
}

const refreshAll = async () => {
  await loadTypes()
  await loadItems()
}

onMounted(async () => {
  await loadTypes()
  await loadItems()
})

// ---------- 字典类型 ----------
const typeDialog = ref(false)
const typeFormRef = ref()
const typeForm = reactive<DictType>({ dictType: '', dictName: '', remark: '' })

const openTypeCreate = () => {
  Object.assign(typeForm, { id: undefined, dictType: '', dictName: '', remark: '' })
  typeDialog.value = true
}

const openTypeEdit = (row: DictType) => {
  Object.assign(typeForm, row)
  typeDialog.value = true
}

const onTypeSave = async () => {
  if (!typeForm.dictType || !typeForm.dictName) {
    ElMessage.warning('字典类型与字典名称都要填写')
    return
  }
  saving.value = true
  try {
    if (typeForm.id) {
      await dictApi.update(typeForm as never)
    } else {
      await dictApi.create(typeForm as never)
      activeType.value = typeForm.dictType
    }
    ElMessage.success('保存成功')
    typeDialog.value = false
    await refreshAll()
    await loadDicts(true)
  } finally {
    saving.value = false
  }
}

const onTypeDelete = async (row: DictType) => {
  await ElMessageBox.confirm(`确认删除字典类型「${row.dictName}」？其下字典项将无法在业务页面显示。`, '危险操作', {
    type: 'warning',
    confirmButtonText: '确认删除',
    confirmButtonClass: 'el-button--danger'
  })
  await dictApi.remove(row.id as number)
  ElMessage.success('删除成功')
  if (activeType.value === row.dictType) {
    activeType.value = ''
  }
  await refreshAll()
  await loadDicts(true)
}

// ---------- 字典项 ----------
const itemDialog = ref(false)
const itemFormRef = ref()
const itemForm = reactive<DictItem>({ dictType: '', itemLabel: '', itemValue: '', sort: 0, status: 1, remark: '' })

const openItemCreate = () => {
  Object.assign(itemForm, { id: undefined, dictType: activeType.value, itemLabel: '', itemValue: '', sort: 0, status: 1, remark: '' })
  itemDialog.value = true
}

const openItemEdit = (row: DictItem) => {
  Object.assign(itemForm, row)
  itemDialog.value = true
}

const onItemSave = async () => {
  if (!itemForm.itemLabel || itemForm.itemValue === '') {
    ElMessage.warning('标签与值都要填写')
    return
  }
  itemForm.dictType = activeType.value
  saving.value = true
  try {
    if (itemForm.id) {
      await dictItemApi.update(itemForm as never)
    } else {
      await dictItemApi.create(itemForm as never)
    }
    ElMessage.success('保存成功')
    itemDialog.value = false
    await loadItems()
    await loadDicts(true)
  } finally {
    saving.value = false
  }
}

const onItemDelete = async (row: DictItem) => {
  await ElMessageBox.confirm(`确认删除字典项「${row.itemLabel}」？`, '危险操作', {
    type: 'warning',
    confirmButtonText: '确认删除',
    confirmButtonClass: 'el-button--danger'
  })
  await dictItemApi.remove(row.id as number)
  ElMessage.success('删除成功')
  await loadItems()
  await loadDicts(true)
}
</script>

<style scoped>
.filter-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.filter-head .title {
  font-weight: 600;
  font-size: 16px;
}
.head-actions {
  display: flex;
  align-items: center;
  gap: 10px;
}
.dict-body {
  display: flex;
  gap: 14px;
  margin-top: 14px;
  align-items: flex-start;
}
.type-card {
  width: 300px;
  flex: none;
}
.item-card {
  flex: 1;
  min-width: 0;
}
.card-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.type-list {
  max-height: calc(100vh - 300px);
  overflow: auto;
}
.type-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 8px 10px;
  border-radius: 6px;
  cursor: pointer;
}
.type-item:hover {
  background: #f5f7fa;
}
.type-item.active {
  background: #ecf5ff;
  box-shadow: inset 2px 0 0 #409eff;
}
.type-name {
  font-size: 14px;
  color: #303133;
}
.type-code {
  font-size: 12px;
  color: #909399;
}
.type-actions {
  display: none;
  white-space: nowrap;
}
.type-item.active .type-actions,
.type-item:hover .type-actions {
  display: block;
}
.tip {
  margin-left: 10px;
  font-size: 12px;
  color: #909399;
}
</style>
