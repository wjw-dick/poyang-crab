<template>
  <div class="sys-storage">
    <!-- 顶部 5 张等大卡片单选驱动 -->
    <el-row :gutter="12" class="driver-cards">
      <el-col v-for="item in drivers" :key="String(item.driver)" :xs="12" :sm="8" :md="4">
        <div class="driver-card" :class="{ active: selected === item.driver }" @click="onSelect(item)">
          <div class="driver-name">{{ item.label }}</div>
          <div class="driver-key">{{ item.driver }}</div>
          <el-tag v-if="item.active" size="small" type="success" effect="dark">使用中</el-tag>
          <el-tag v-else-if="item.testPassed" size="small" type="info">已测试通过</el-tag>
          <el-tag v-else size="small" type="info" effect="plain">未测试</el-tag>
        </div>
      </el-col>
    </el-row>

    <!-- 选中后才动态滑出对应参数表单（未选中驱动字段完全不渲染） -->
    <el-card v-if="selected" shadow="never" class="param-card">
      <template #header>
        <span>{{ driverLabel(selected) }} 参数配置</span>
      </template>
      <el-form label-width="140px">
        <el-form-item v-for="field in paramFields" :key="field.key" :label="field.label">
          <el-input
            v-if="field.secret"
            v-model="params[field.key]"
            type="password"
            show-password
            placeholder="未修改则沿用原密钥"
          />
          <el-input v-else v-model="params[field.key]" :placeholder="field.placeholder" />
          <div class="field-tip">{{ field.tip }}</div>
        </el-form-item>
      </el-form>

      <div class="actions">
        <el-button :loading="testing" @click="onTest">连接测试</el-button>
        <el-tooltip :disabled="testPassed" content="连接测试通过后才可保存并应用" placement="top">
          <span>
            <el-button type="primary" :disabled="!testPassed" :loading="applying" @click="onApply">保存并应用</el-button>
          </span>
        </el-tooltip>
        <span v-if="testPassed" class="ok-tip">已通过连接测试</span>
        <span v-else class="fail-tip">未通过连接测试</span>
      </div>
    </el-card>

    <el-empty v-else description="请先选择对象存储驱动" />
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { storageApi } from '@/api'

/**
 * T12 对象存储配置页
 * 交互红线：5 张等大卡片单选 → 动态滑出参数表单（未选中不渲染）
 *          → AK/SK 密码框 + 眼睛切换 → 连接测试通过才亮「保存并应用」→ 切换驱动二次确认
 */
interface ParamField {
  key: string
  label: string
  secret?: boolean
  placeholder?: string
  tip?: string
}

const FIELDS: Record<string, ParamField[]> = {
  LOCAL: [
    { key: 'basePath', label: '存储根目录', placeholder: '/data/upload', tip: '本地磁盘目录，需保证容器可写' },
    { key: 'domain', label: '访问域名', placeholder: 'https://xiegongzhu.com/files', tip: '对外访问前缀' }
  ],
  S3: [
    { key: 'endpoint', label: 'Endpoint', placeholder: 'https://s3.amazonaws.com' },
    { key: 'region', label: 'Region', placeholder: 'ap-east-1' },
    { key: 'bucket', label: 'Bucket' },
    { key: 'accessKey', label: 'Access Key', secret: true },
    { key: 'secretKey', label: 'Secret Key', secret: true },
    { key: 'domain', label: 'CDN 域名', tip: '可选，配置后返回该域名拼接的 URL' }
  ],
  OSS: [
    { key: 'endpoint', label: 'Endpoint', placeholder: 'oss-cn-hangzhou.aliyuncs.com' },
    { key: 'bucket', label: 'Bucket' },
    { key: 'accessKeyId', label: 'AccessKeyId', secret: true },
    { key: 'accessKeySecret', label: 'AccessKeySecret', secret: true },
    { key: 'domain', label: 'CDN 域名' }
  ],
  COS: [
    { key: 'region', label: 'Region', placeholder: 'ap-guangzhou' },
    { key: 'bucket', label: 'Bucket' },
    { key: 'secretId', label: 'SecretId', secret: true },
    { key: 'secretKey', label: 'SecretKey', secret: true },
    { key: 'domain', label: 'CDN 域名' }
  ],
  MINIO: [
    { key: 'endpoint', label: 'Endpoint', placeholder: 'http://minio:9000' },
    { key: 'bucket', label: 'Bucket', placeholder: 'xiegongzhu' },
    { key: 'accessKey', label: 'Access Key', secret: true },
    { key: 'secretKey', label: 'Secret Key', secret: true },
    { key: 'domain', label: '访问域名' }
  ]
}

const GROUP_LABELS: Record<string, string> = { LOCAL: '本地磁盘', S3: 'S3', OSS: '阿里云 OSS', COS: '腾讯云 COS', MINIO: 'MinIO' }

const drivers = ref<Array<Record<string, unknown>>>([])
const selected = ref<string>('')
const params = reactive<Record<string, string>>({})
const testing = ref(false)
const applying = ref(false)
const testPassed = ref(false)

const paramFields = computed(() => FIELDS[selected.value] || [])
const driverLabel = (driver: string) => GROUP_LABELS[driver] || driver

const load = async () => {
  drivers.value = (await storageApi.drivers()) as never
  const active = drivers.value.find((item) => item.active)
  if (active) {
    selectDriver(String(active.driver), active)
  }
}

const selectDriver = (driver: string, item?: Record<string, unknown>) => {
  selected.value = driver
  Object.keys(params).forEach((key) => delete params[key])
  paramFields.value.forEach((field) => {
    params[field.key] = ''
  })
  const source = item || drivers.value.find((row) => row.driver === driver)
  const stored = (source?.params || {}) as Record<string, string>
  Object.keys(stored).forEach((key) => {
    params[key] = stored[key] == null ? '' : stored[key]
  })
  testPassed.value = Boolean(source?.testPassed)
}

const onSelect = async (item: Record<string, unknown>) => {
  const driver = String(item.driver)
  if (selected.value && selected.value !== driver) {
    await ElMessageBox.confirm(
      `将切换对象存储驱动为「${driverLabel(driver)}」，切换后新上传文件走新驱动，历史文件地址保持不变。确认继续？`,
      '切换驱动确认',
      { type: 'warning', confirmButtonText: '确认切换', confirmButtonClass: 'el-button--warning' }
    )
  }
  selectDriver(driver, item)
}

const onTest = async () => {
  testing.value = true
  try {
    testPassed.value = await storageApi.test(selected.value, { ...params })
    ElMessage[testPassed.value ? 'success' : 'error'](testPassed.value ? '连接测试通过' : '连接测试失败，请检查参数')
  } finally {
    testing.value = false
  }
}

const onApply = async () => {
  applying.value = true
  try {
    await storageApi.apply(selected.value, { ...params })
    ElMessage.success('保存并应用成功')
    load()
  } finally {
    applying.value = false
  }
}

onMounted(load)
</script>

<style scoped>
.driver-cards {
  margin-bottom: 12px;
}
.driver-card {
  height: 108px;
  padding: 14px;
  border: 2px solid #e5e7eb;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.18s;
  display: flex;
  flex-direction: column;
  gap: 6px;
  background: #fff;
}
.driver-card:hover {
  border-color: #c6d9f7;
}
.driver-card.active {
  border-color: #409eff;
  box-shadow: 0 6px 16px rgba(64, 158, 255, 0.18);
}
.driver-name {
  font-weight: 600;
}
.driver-key {
  color: #9ca3af;
  font-size: 12px;
  flex: 1;
}
.param-card {
  max-width: 720px;
}
.field-tip {
  width: 100%;
  color: #c0c4cc;
  font-size: 12px;
}
.actions {
  display: flex;
  align-items: center;
  gap: 12px;
  padding-left: 140px;
}
.ok-tip {
  color: #67c23a;
  font-size: 12px;
}
.fail-tip {
  color: #f56c6c;
  font-size: 12px;
}
</style>
