<template>
  <div class="sys-i18n">
    <!-- 语言列表 -->
    <el-card shadow="never" class="lang-card">
      <template #header>
        <div class="head">
          <span>语言列表</span>
          <el-button type="primary" size="small" @click="openLang()">新增语言</el-button>
        </div>
      </template>
      <el-table :data="langs" stripe size="small">
        <el-table-column prop="langCode" label="语言代码" width="140" />
        <el-table-column prop="langName" label="名称" />
        <el-table-column prop="sort" label="排序" width="80" />
        <el-table-column label="默认" width="90">
          <template #default="{ row }">
            <el-tag v-if="row.isDefault === 1" type="success" size="small">默认</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="150">
          <template #default="{ row }">
            <el-button link type="primary" @click="openLang(row)">编辑</el-button>
            <el-button link type="danger" @click="removeLang(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 词条：多语言 tab 编辑 -->
    <el-card shadow="never">
      <template #header>
        <div class="head">
          <span>多语言词条</span>
          <div>
            <el-input v-model="keyword" placeholder="搜索词条键" style="width: 200px" clearable @change="loadI18n" />
            <el-button type="primary" size="small" style="margin-left: 8px" @click="openI18n()">新增词条</el-button>
          </div>
        </div>
      </template>

      <el-tabs v-model="activeLang">
        <el-tab-pane v-for="lang in langs" :key="lang.langCode" :label="lang.langName" :name="lang.langCode">
          <el-table :data="i18nList" stripe size="small" height="420">
            <el-table-column prop="itemKey" label="词条键" width="260" />
            <el-table-column label="内容">
              <template #default="{ row }">
                <el-input v-model="row.itemValue" placeholder="未填写则该语言回退默认语言" @change="saveInline(row)" />
              </template>
            </el-table-column>
          </el-table>
        </el-tab-pane>
      </el-tabs>
    </el-card>

    <el-dialog v-model="langDialog" :title="langForm.id ? '编辑语言' : '新增语言'" width="480px">
      <el-form :model="langForm" label-width="90px">
        <el-form-item label="语言代码"><el-input v-model="langForm.langCode" placeholder="en-US" /></el-form-item>
        <el-form-item label="名称"><el-input v-model="langForm.langName" placeholder="English" /></el-form-item>
        <el-form-item label="是否默认"><el-switch v-model="langForm.isDefault" :active-value="1" :inactive-value="0" /></el-form-item>
        <el-form-item label="排序"><el-input-number v-model="langForm.sort" :min="0" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="langDialog = false">取消</el-button>
        <el-button type="primary" @click="saveLang">确定</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="i18nDialog" title="新增词条" width="560px">
      <el-form :model="i18nForm" label-width="90px">
        <el-form-item label="词条键"><el-input v-model="i18nForm.itemKey" placeholder="home.title" /></el-form-item>
        <el-form-item label="语言"><el-input v-model="i18nForm.langCode" :disabled="true" /></el-form-item>
        <el-form-item label="内容"><el-input v-model="i18nForm.itemValue" type="textarea" :rows="3" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="i18nDialog = false">取消</el-button>
        <el-button type="primary" @click="saveI18n">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { createCrudApi } from '@/api'

/**
 * T09 多语言 i18n：语言列表 + 内容多语言字段（tab）+ 前台切换器所需词条包
 * 前台切换器数据源：GET /api/portal/i18n/{langCode}
 */
const langApi = createCrudApi('/system/lang')
const i18nApi = createCrudApi('/system/i18n')

const langs = ref<Array<Record<string, any>>>([])
const i18nList = ref<Array<Record<string, any>>>([])
const activeLang = ref('zh-CN')
const keyword = ref('')

const langDialog = ref(false)
const i18nDialog = ref(false)
const langForm = reactive<Record<string, any>>({ sort: 0, isDefault: 0, status: 1 })
const i18nForm = reactive<Record<string, any>>({ langCode: 'zh-CN', itemValue: '' })

const loadLangs = async () => {
  const page = await langApi.page({ current: 1, size: 100 })
  langs.value = page.records as never
  if (langs.value.length && !langs.value.find((item) => item.langCode === activeLang.value)) {
    activeLang.value = langs.value[0].langCode
  }
  loadI18n()
}

const loadI18n = async () => {
  const page = await i18nApi.page({ current: 1, size: 500, langCode: activeLang.value, itemKey: keyword.value })
  i18nList.value = (page.records as never) || []
}

const openLang = (row?: Record<string, any>) => {
  Object.keys(langForm).forEach((key) => delete langForm[key])
  Object.assign(langForm, row || { langCode: '', langName: '', isDefault: 0, sort: 0, status: 1 })
  langDialog.value = true
}

const saveLang = async () => {
  if (langForm.id) await langApi.update(langForm)
  else await langApi.create(langForm)
  ElMessage.success('保存成功')
  langDialog.value = false
  loadLangs()
}

const removeLang = async (row: Record<string, any>) => {
  await langApi.remove(row.id)
  ElMessage.success('删除成功')
  loadLangs()
}

const openI18n = () => {
  Object.keys(i18nForm).forEach((key) => delete i18nForm[key])
  Object.assign(i18nForm, { itemKey: '', langCode: activeLang.value, itemValue: '' })
  i18nDialog.value = true
}

const saveI18n = async () => {
  await i18nApi.create(i18nForm)
  ElMessage.success('保存成功')
  i18nDialog.value = false
  loadI18n()
}

/** 行内编辑保存（富文本语言 tab 同步落库） */
const saveInline = async (row: Record<string, any>) => {
  await i18nApi.update(row)
  ElMessage.success('已保存')
}

onMounted(loadLangs)
</script>

<style scoped>
.lang-card {
  margin-bottom: 12px;
}
.head {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
</style>
