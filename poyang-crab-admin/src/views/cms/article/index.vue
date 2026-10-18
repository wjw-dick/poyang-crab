<template>
  <div class="cms-article">
    <el-card class="filter-card" shadow="never">
      <div class="filter-head">
        <span class="title">文章管理（双语 SEO）</span>
        <div>
          <el-button type="primary" @click="openEdit()">新增文章</el-button>
          <el-button @click="load">刷新</el-button>
        </div>
      </div>
    </el-card>

    <el-card shadow="never">
      <el-table v-loading="loading" :data="list" stripe border>
        <el-table-column prop="title" label="标题" />
        <el-table-column prop="titleEn" label="英文标题" show-overflow-tooltip />
        <el-table-column prop="categoryId" label="栏目" width="140">
          <template #default="{ row }">{{ lookupLabel('cmsCategory', row.categoryId) }}</template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="110">
          <template #default="{ row }">
            <el-tag :type="row.status === 'PUBLISHED' ? 'success' : 'info'" size="small">
              {{ dictLabel('article_status', row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="isTop" label="置顶" width="80">
          <template #default="{ row }">{{ row.isTop === 1 ? '是' : '否' }}</template>
        </el-table-column>
        <el-table-column prop="viewCount" label="浏览量" width="90" />
        <el-table-column prop="publishTime" label="发布时间" width="170" />
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="openEdit(row)">编辑</el-button>
            <el-button link type="danger" @click="onDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <div class="table-pagination">
        <el-pagination
          background
          layout="total, sizes, prev, pager, next"
          :total="total"
          :current-page="Number(query.current)"
          :page-size="Number(query.size)"
          @current-change="onPageChange"
          @size-change="onSizeChange"
        />
      </div>
    </el-card>

    <!-- 编辑：左右分栏 + 富文本语言 tab + SEO 字段 -->
    <el-drawer v-model="drawerVisible" :title="form.id ? '编辑文章' : '新增文章'" size="1100px">
      <div class="form-split">
        <div class="form-split__main">
          <el-form :model="form" label-width="100px">
            <el-form-item label="栏目">
              <el-select v-model="form.categoryId" style="width: 100%" placeholder="品牌故事 / 养殖基地 / 捕捞实景 / 招商">
                <el-option v-for="item in categories" :key="item.id" :label="item.categoryName" :value="item.id" />
              </el-select>
            </el-form-item>
            <el-form-item label="封面">
              <div class="form-row-full">
                <ImageUpload v-model="coverImages" :max-count="1" biz-type="cms" />
              </div>
            </el-form-item>
            <el-form-item label="正文（多语言）">
              <el-tabs v-model="activeLang" style="width: 100%">
                <el-tab-pane label="简体中文" name="zh-CN">
                  <RichEditor v-model="form.contentHtml" biz-type="cms" :height="380" />
                </el-tab-pane>
                <el-tab-pane label="English" name="en-US">
                  <RichEditor v-model="form.contentHtmlEn" biz-type="cms" :height="380" />
                </el-tab-pane>
              </el-tabs>
            </el-form-item>
          </el-form>
        </div>
        <div class="form-split__side">
          <el-card shadow="never">
            <template #header>基础与 SEO</template>
            <el-form :model="form" label-position="top">
              <el-form-item label="标题"><el-input v-model="form.title" /></el-form-item>
              <el-form-item label="English Title"><el-input v-model="form.titleEn" /></el-form-item>
              <el-form-item label="摘要"><el-input v-model="form.summary" type="textarea" :rows="2" /></el-form-item>
              <el-form-item label="SEO 标题"><el-input v-model="form.seoTitle" /></el-form-item>
              <el-form-item label="SEO 关键词"><el-input v-model="form.seoKeywords" /></el-form-item>
              <el-form-item label="SEO 描述"><el-input v-model="form.seoDesc" type="textarea" :rows="2" /></el-form-item>
              <el-form-item label="置顶"><el-switch v-model="form.isTop" :active-value="1" :inactive-value="0" /></el-form-item>
              <el-form-item label="状态">
                <el-select v-model="form.status" style="width: 100%">
                  <el-option v-for="opt in articleStatusOptions" :key="opt.value" :label="opt.label" :value="opt.value" />
                </el-select>
              </el-form-item>
            </el-form>
          </el-card>
        </div>
      </div>
      <template #footer>
        <el-button @click="drawerVisible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="onSave">保存</el-button>
      </template>
    </el-drawer>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import ImageUpload from '@/components/ImageUpload/index.vue'
import RichEditor from '@/components/RichEditor/index.vue'
import { bizApi, createCrudApi } from '@/api'
import { useTable } from '@/composables/useTable'
import { dictLabel, dictOptions, loadDicts } from '@/composables/useDict'
import { loadLookup, lookupLabel } from '@/composables/useLookup'

/**
 * T11 富文本 CMS：WangEditor（禁止 textarea）+ 图片走对象存储 + 多语言 tab + 双语 SEO
 * 文章状态走字典（article_status），所属栏目显示名称
 */
const articleStatusOptions = computed(() => dictOptions('article_status'))
const productCategoryApi = createCrudApi('/cms/category')
const { loading, list, total, query, load, onPageChange, onSizeChange } = useTable((params) =>
  bizApi.article.page(params) as never
)

const categories = ref<Array<Record<string, any>>>([])
const drawerVisible = ref(false)
const saving = ref(false)
const activeLang = ref('zh-CN')
const form = reactive<Record<string, any>>({})
const coverImages = ref<string[]>([])

const loadCategories = async () => {
  const page = await productCategoryApi.page({ current: 1, size: 100 })
  categories.value = (page.records as never) || []
}

const openEdit = (row?: Record<string, any>) => {
  Object.keys(form).forEach((key) => delete form[key])
  Object.assign(form, row || { status: 'DRAFT', isTop: 0, viewCount: 0, contentHtml: '', contentHtmlEn: '' })
  coverImages.value = form.cover ? [form.cover] : []
  drawerVisible.value = true
}

const onSave = async () => {
  saving.value = true
  try {
    const payload = { ...form, cover: coverImages.value[0] || '' }
    if (form.id) await bizApi.article.update(payload)
    else await bizApi.article.create(payload)
    ElMessage.success('保存成功')
    drawerVisible.value = false
    load()
  } finally {
    saving.value = false
  }
}

const onDelete = async (row: Record<string, any>) => {
  await ElMessageBox.confirm('确认删除该文章？', '危险操作', {
    type: 'warning',
    confirmButtonText: '确认删除',
    confirmButtonClass: 'el-button--danger'
  })
  await bizApi.article.remove(row.id)
  ElMessage.success('删除成功')
  load()
}

onMounted(async () => {
  await Promise.all([loadDicts(), loadLookup('cmsCategory')])
  loadCategories()
  load()
})
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
</style>
