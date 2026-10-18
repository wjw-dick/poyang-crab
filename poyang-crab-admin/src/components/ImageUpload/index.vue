<template>
  <!-- T13 图片上传组件：独立卡片块「独占整行」，不与名称/价格/文本域并排 -->
  <div class="image-upload">
    <el-upload
      drag
      multiple
      :show-file-list="false"
      :auto-upload="false"
      accept="image/*"
      :on-change="onFileChange"
      class="upload-dragger"
    >
      <el-icon class="upload-icon"><UploadFilled /></el-icon>
      <div class="upload-text">将图片拖到此处，或<em>点击上传</em></div>
      <div class="upload-tip">支持 jpg/png/webp，单张不超过 10MB；可多选并行上传，失败可单张重试</div>
    </el-upload>

    <!-- 缩略图网格：拖拽调序 / 点击放大 / 批量删除 / 上传中进度条 / 失败重试 -->
    <div v-if="files.length" class="thumb-grid">
      <div v-for="(item, index) in files" :key="item.uid" class="thumb-item" :class="{ failed: item.status === 'fail' }">
        <el-image
          v-if="item.status === 'done'"
          :src="item.url"
          :preview-src-list="previewList"
          :initial-index="index"
          fit="cover"
          class="thumb-img"
        />
        <div v-else class="thumb-placeholder">
          <el-icon><Picture /></el-icon>
        </div>

        <el-progress
          v-if="item.status === 'uploading'"
          :percentage="item.progress"
          :stroke-width="4"
          class="thumb-progress"
        />
        <div v-if="item.status === 'fail'" class="thumb-retry" @click.stop="retry(item)">
          <el-icon><RefreshRight /></el-icon>
          重试
        </div>
        <div class="thumb-actions">
          <el-icon class="drag-handle"><Rank /></el-icon>
          <el-icon class="remove" @click.stop="remove(index)"><Delete /></el-icon>
        </div>
      </div>
    </div>

    <div v-if="files.length" class="thumb-footer">
      <el-button link type="danger" @click="removeAll">批量删除</el-button>
      <span class="count">共 {{ files.length }} 张</span>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, nextTick, ref, watch } from 'vue'
import { ElMessage, type UploadFile } from 'element-plus'
import Sortable from 'sortablejs'
import { fileApi } from '@/api'

interface UploadItem {
  uid: number
  url: string
  name: string
  raw?: File
  status: 'uploading' | 'done' | 'fail'
  progress: number
}

const props = withDefaults(
  defineProps<{
    /** 已保存的图片 URL 列表（v-model） */
    modelValue?: string[]
    /** 对象存储业务目录 */
    bizType?: string
    maxCount?: number
  }>(),
  { modelValue: () => [], bizType: 'common', maxCount: 20 }
)

const emit = defineEmits<{ (e: 'update:modelValue', value: string[]): void }>()

const files = ref<UploadItem[]>(
  props.modelValue.map((url, index) => ({ uid: -index - 1, url, name: url, status: 'done', progress: 100 }))
)

const previewList = computed(() => files.value.filter((item) => item.status === 'done').map((item) => item.url))

watch(
  () => props.modelValue,
  (value) => {
    const current = files.value.map((item) => item.url).join(',')
    if (value.join(',') !== current) {
      files.value = value.map((url, index) => ({ uid: -index - 1, url, name: url, status: 'done', progress: 100 }))
    }
  }
)

const syncModel = () => {
  emit('update:modelValue', files.value.filter((item) => item.status === 'done').map((item) => item.url))
}

const onFileChange = async (file: UploadFile) => {
  if (props.maxCount && files.value.length >= props.maxCount) {
    ElMessage.warning(`最多上传 ${props.maxCount} 张`)
    return
  }
  const item: UploadItem = {
    uid: file.uid ?? Date.now(),
    url: '',
    name: file.name,
    raw: file.raw,
    status: 'uploading',
    progress: 10
  }
  files.value.push(item)
  await doUpload(item)
}

const doUpload = async (item: UploadItem) => {
  if (!item.raw) {
    item.status = 'fail'
    return
  }
  item.status = 'uploading'
  item.progress = 30
  try {
    const result = await fileApi.upload(item.raw, props.bizType)
    item.url = result.url
    item.progress = 100
    item.status = 'done'
    syncModel()
  } catch (error) {
    item.status = 'fail'
    ElMessage.error(`「${item.name}」上传失败，可点击重试`)
  }
}

const retry = (item: UploadItem) => doUpload(item)

const remove = (index: number) => {
  files.value.splice(index, 1)
  syncModel()
}

const removeAll = () => {
  files.value = []
  syncModel()
}

/** 拖拽调序（缩略图网格顺序即最终顺序） */
const initSortable = () => {
  const grid = document.querySelector('.thumb-grid')
  if (grid) {
    Sortable.create(grid as HTMLElement, {
      handle: '.drag-handle',
      animation: 150,
      onEnd: ({ oldIndex, newIndex }) => {
        if (oldIndex === undefined || newIndex === undefined) return
        const moved = files.value.splice(oldIndex, 1)[0]
        files.value.splice(newIndex, 0, moved)
        syncModel()
      }
    })
  }
}

watch(files, () => nextTick(initSortable), { immediate: true })
</script>

<style scoped>
.image-upload {
  width: 100%;
}
.upload-dragger :deep(.el-upload-dragger) {
  padding: 24px;
}
.upload-icon {
  font-size: 40px;
  color: #c0c4cc;
}
.upload-text {
  margin-top: 8px;
  font-size: 14px;
}
.upload-text em {
  color: #409eff;
  font-style: normal;
}
.upload-tip {
  margin-top: 6px;
  font-size: 12px;
  color: #909399;
}
.thumb-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-top: 14px;
}
.thumb-item {
  position: relative;
  width: 108px;
  height: 108px;
  border: 1px solid #e4e7ed;
  border-radius: 6px;
  overflow: hidden;
  background: #f7f8fa;
}
.thumb-item.failed {
  border-color: #f56c6c;
}
.thumb-img,
.thumb-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 26px;
  color: #c0c4cc;
}
.thumb-progress {
  position: absolute;
  left: 0;
  right: 0;
  bottom: 6px;
  padding: 0 6px;
}
.thumb-retry {
  position: absolute;
  inset: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 4px;
  color: #f56c6c;
  font-size: 12px;
  cursor: pointer;
  background: rgba(255, 255, 255, 0.86);
}
.thumb-actions {
  position: absolute;
  top: 0;
  right: 0;
  display: none;
  gap: 6px;
  padding: 4px;
  background: rgba(0, 0, 0, 0.45);
  color: #fff;
}
.thumb-item:hover .thumb-actions {
  display: flex;
}
.thumb-actions .drag-handle {
  cursor: move;
}
.thumb-actions .remove {
  cursor: pointer;
}
.thumb-footer {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-top: 8px;
  font-size: 12px;
  color: #909399;
}
</style>
