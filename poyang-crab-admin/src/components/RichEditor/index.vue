<template>
  <!-- T11 富文本编辑器：WangEditor 5（禁止 textarea） -->
  <div class="rich-editor-wrap">
    <Toolbar class="rich-toolbar" :editor="editorRef" :default-config="toolbarConfig" mode="default" />
    <Editor
      v-model="valueHtml"
      class="rich-body"
      :style="{ height: height + 'px' }"
      :default-config="editorConfig"
      mode="default"
      @on-created="handleCreated"
    />
  </div>
</template>

<script setup lang="ts">
import { onBeforeUnmount, ref, shallowRef, watch } from 'vue'
import '@wangeditor/editor/dist/css/style.css'
import { Editor, Toolbar } from '@wangeditor/editor-for-vue'
import type { IDomEditor, IEditorConfig, IToolbarConfig } from '@wangeditor/editor'
import { ElMessage } from 'element-plus'
import { fileApi } from '@/api'

const props = withDefaults(defineProps<{ modelValue?: string; height?: number; bizType?: string }>(), {
  modelValue: '',
  height: 420,
  bizType: 'rich-text'
})
const emit = defineEmits<{ (e: 'update:modelValue', value: string): void }>()

const editorRef = shallowRef<IDomEditor>()
const valueHtml = ref(props.modelValue)

// 工具栏齐全：标题 H1-H3 / 加粗 / 颜色 / 对齐 / 图片 / 视频 / 表格 / 链接 / 源码 / 全屏
const toolbarConfig: Partial<IToolbarConfig> = {
  toolbarKeys: [
    'headerSelect', 'blockquote', '|',
    'bold', 'underline', 'italic', 'through', 'color', 'bgColor', '|',
    'fontSize', 'fontFamily', 'lineHeight', '|',
    'bulletedList', 'numberedList', 'todo', 'justifyLeft', 'justifyCenter', 'justifyRight', '|',
    'insertLink', 'insertImage', 'uploadImage', 'insertVideo', 'insertTable', 'codeBlock', '|',
    'undo', 'redo', '|', 'fullScreen', 'clearStyle'
  ]
}

const editorConfig: Partial<IEditorConfig> = {
  placeholder: '请输入内容（支持粘贴图片，自动上传至对象存储）',
  MENU_CONF: {
    // 粘贴即上传 / 上传图片走对象存储（T11）
    uploadImage: {
      async customUpload(file: File, insertFn: (url: string, alt: string, href: string) => void) {
        try {
          const result = await fileApi.upload(file, props.bizType)
          insertFn(result.url, file.name, result.url)
        } catch (error) {
          ElMessage.error('图片上传失败，请重试')
        }
      }
    },
    uploadVideo: {
      async customUpload(file: File, insertFn: (url: string, poster: string) => void) {
        try {
          const result = await fileApi.upload(file, 'video')
          insertFn(result.url, '')
        } catch (error) {
          ElMessage.error('视频上传失败，请重试')
        }
      }
    }
  }
}

const handleCreated = (editor: IDomEditor) => {
  editorRef.value = editor
}

watch(
  () => props.modelValue,
  (value) => {
    if (value !== valueHtml.value) {
      valueHtml.value = value
    }
  }
)

watch(valueHtml, (value) => emit('update:modelValue', value))

onBeforeUnmount(() => {
  editorRef.value?.destroy()
})
</script>

<style scoped>
.rich-toolbar {
  border-bottom: 1px solid #e4e7ed;
}
</style>
