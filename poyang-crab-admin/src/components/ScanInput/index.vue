<template>
  <div class="scan-input">
    <el-input
      :model-value="modelValue"
      :placeholder="placeholder || '请输入或扫码录入'"
      clearable
      @update:model-value="onInput"
    >
      <template #append>
        <el-button class="scan-trigger" @click="openScanner">
          <el-icon><FullScreen /></el-icon>
          <span>扫码</span>
        </el-button>
      </template>
    </el-input>

    <!-- 摄像头扫码：条形码（顺丰运单号多为 CODE_128）+ 二维码 -->
    <el-dialog
      v-model="visible"
      title="扫码录入"
      width="560px"
      append-to-body
      destroy-on-close
      @closed="stopScanner"
    >
      <div class="scan-body">
        <div :id="readerId" ref="readerRef" class="scan-reader" :class="{ 'is-idle': !scanning }"></div>
        <p class="scan-tip">{{ tip }}</p>
        <p class="scan-hint">
          支持条形码 / 二维码。若本机没有摄像头或未授权，可直接用扫码枪录入（扫码枪等同键盘输入），也可手工填写。
        </p>
      </div>
      <template #footer>
        <el-button @click="visible = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
/**
 * 扫码录入输入框：输入框 + 「扫码」按钮。
 *
 * PC 后台没有微信扫一扫，这里用摄像头 + html5-qrcode 在前端解码；
 * 生产环境的扫码枪走「键盘输入」路径，直接敲进同一个输入框即可，无需额外适配。
 */
import { nextTick, onBeforeUnmount, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { FullScreen } from '@element-plus/icons-vue'
import { Html5Qrcode, Html5QrcodeSupportedFormats } from 'html5-qrcode'

const props = withDefaults(
  defineProps<{
    modelValue?: string
    /** 为空时使用默认提示语 */
    placeholder?: string
  }>(),
  { modelValue: '', placeholder: '' }
)

const emit = defineEmits<{
  (e: 'update:modelValue', value: string): void
  (e: 'scan', value: string): void
}>()

/** 顺丰运单号等常见物流条码格式 + 二维码 */
const FORMATS = [
  Html5QrcodeSupportedFormats.CODE_128,
  Html5QrcodeSupportedFormats.CODE_39,
  Html5QrcodeSupportedFormats.CODE_93,
  Html5QrcodeSupportedFormats.CODABAR,
  Html5QrcodeSupportedFormats.ITF,
  Html5QrcodeSupportedFormats.EAN_13,
  Html5QrcodeSupportedFormats.EAN_8,
  Html5QrcodeSupportedFormats.UPC_A,
  Html5QrcodeSupportedFormats.UPC_E,
  Html5QrcodeSupportedFormats.QR_CODE
]

const visible = ref(false)
const scanning = ref(false)
const tip = ref('')
const readerRef = ref<HTMLElement>()
/** html5-qrcode 只接收元素 id（字符串），这里给每个实例分配唯一 id，避免多表单并存时互相覆盖 */
const readerId = `scan-reader-${Math.random().toString(36).slice(2, 9)}`
let scanner: Html5Qrcode | null = null

const onInput = (value: string) => emit('update:modelValue', value)

const openScanner = async () => {
  visible.value = true
  await nextTick()
  // 无摄像头能力（部分内网浏览器 / 未授权）直接降级提示，不去调 getUserMedia
  if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
    tip.value = '当前浏览器不支持调用摄像头。请使用扫码枪录入（等同键盘输入）或手工填写。'
    return
  }
  tip.value = '正在打开摄像头…'
  try {
    scanner = new Html5Qrcode(readerId, {
      formatsToSupport: FORMATS,
      verbose: false
    })
    const started = scanner.start(
      { facingMode: 'environment' },
      { fps: 10, qrbox: { width: 300, height: 160 } },
      (decodedText) => onDecoded(decodedText),
      () => {
        /* 单帧未识别：静默忽略，持续扫描 */
      }
    )
    // 摄像头被拦截 / 无设备时 start 可能长时间不返回，加超时兜底，保证弹窗始终有明确提示
    const timeout = new Promise<boolean>((resolve) => setTimeout(() => resolve(false), 8000))
    const ok = await Promise.race([started.then(() => true).catch(() => false), timeout])
    if (ok) {
      scanning.value = true
      tip.value = '请将条形码对准取景框，识别成功后自动填入'
    } else {
      tip.value =
        '摄像头打开超时：可能未授权或本机无摄像头。可改用扫码枪录入（等同键盘输入）或手工填写；若浏览器稍后弹出授权，允许后仍可继续扫码。'
      started
        .then(() => {
          scanning.value = true
          tip.value = '摄像头已就绪，请将条形码对准取景框'
        })
        .catch(() => {
          /* 已在下方提示，无需重复报错 */
        })
    }
  } catch (error) {
    scanning.value = false
    const reason = error instanceof Error ? error.message : String(error)
    tip.value = `无法打开摄像头：${reason}`
    ElMessage.warning('未获取到摄像头，可用扫码枪或手工录入')
  }
}

const onDecoded = (text: string) => {
  const value = (text || '').trim()
  if (!value) {
    return
  }
  emit('update:modelValue', value)
  emit('scan', value)
  ElMessage.success(`扫码成功：${value}`)
  visible.value = false
}

const stopScanner = async () => {
  if (!scanner) {
    return
  }
  const instance = scanner
  scanner = null
  scanning.value = false
  try {
    await instance.stop()
  } catch (error) {
    /* 未启动/已停止时 stop 会抛错，忽略即可 */
  }
  try {
    instance.clear()
  } catch (error) {
    /* 同上 */
  }
}

onBeforeUnmount(stopScanner)
</script>

<style scoped>
.scan-input :deep(.el-input-group__append) {
  padding: 0;
  background: #fff;
}
.scan-trigger {
  border: none;
  border-radius: 0 4px 4px 0;
}
.scan-body {
  text-align: center;
}
.scan-reader {
  width: 100%;
  min-height: 240px;
  border-radius: 6px;
  background: #0f172a;
  overflow: hidden;
}
.scan-reader.is-idle {
  display: flex;
  align-items: center;
  justify-content: center;
}
.scan-tip {
  margin: 12px 0 4px;
  font-size: 14px;
  color: #303133;
}
.scan-hint {
  margin: 0;
  font-size: 12px;
  line-height: 1.6;
  color: #909399;
}
</style>
