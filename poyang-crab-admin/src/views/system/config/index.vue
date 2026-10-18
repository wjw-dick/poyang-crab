<template>
  <div class="sys-config">
    <el-card shadow="never" class="header-card">
      <div class="head">
        <span class="title">系统全局参数</span>
        <div>
          <el-button @click="load">重新加载</el-button>
          <el-button type="primary" :loading="saving" @click="onSave">保存</el-button>
        </div>
      </div>
      <p class="tip">站点 / ICP / 客服 / 微信 / 支付 / 存储 / 业务比例；金额与比例全部在此维护，代码中不写死。密钥字段以掩码回显，未修改则沿用原值。</p>
    </el-card>

    <el-card shadow="never">
      <el-tabs v-model="activeGroup">
        <el-tab-pane v-for="(items, group) in grouped" :key="group" :label="groupLabel(String(group))" :name="String(group)">
          <div class="form-split">
            <div class="form-split__main">
              <el-form label-width="220px" v-loading="loading">
                <el-form-item v-for="item in items" :key="String(item.configKey)" :label="String(item.configName)">
                  <el-switch
                    v-if="item.valueType === 'BOOL'"
                    v-model="values[String(item.configKey)]"
                    active-value="true"
                    inactive-value="false"
                  />
                  <el-input
                    v-else-if="item.isEncrypted === 1"
                    v-model="values[String(item.configKey)]"
                    type="password"
                    show-password
                    :placeholder="item.configValue ? '未修改则沿用原密钥' : '请输入'"
                  />
                  <el-input v-else v-model="values[String(item.configKey)]" />
                  <div class="key-tip">{{ item.configKey }}</div>
                </el-form-item>
              </el-form>
            </div>
            <div class="form-split__side">
              <el-card shadow="never" class="side-card">
                <template #header>参数分组</template>
                <ul class="group-list">
                  <li v-for="(items, group) in grouped" :key="group" :class="{ active: activeGroup === String(group) }" @click="activeGroup = String(group)">
                    {{ groupLabel(String(group)) }}
                    <el-tag size="small" type="info">{{ items.length }}</el-tag>
                  </li>
                </ul>
              </el-card>
              <el-alert
                type="warning"
                :closable="false"
                title="存储驱动请前往「对象存储」页配置：先选驱动卡片 → 连接测试通过 → 保存并应用。"
                style="margin-top: 12px"
              />
            </div>
          </div>
        </el-tab-pane>
      </el-tabs>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { configApi } from '@/api'

/**
 * T08 系统全局参数可视化配置页
 */
const loading = ref(false)
const saving = ref(false)
const grouped = ref<Record<string, Array<Record<string, unknown>>>>({})
const values = reactive<Record<string, string>>({})
const activeGroup = ref('SITE')

const GROUP_LABELS: Record<string, string> = {
  SITE: '站点信息',
  ICP: '备案信息',
  SERVICE: '客服配置',
  WECHAT: '微信配置',
  PAY: '支付配置',
  STORAGE: '存储配置',
  BUSINESS: '业务规则'
}

const groupLabel = (group: string) => GROUP_LABELS[group] || group

const load = async () => {
  loading.value = true
  try {
    grouped.value = (await configApi.grouped()) as never
    Object.values(grouped.value).forEach((items) => {
      items.forEach((item) => {
        values[String(item.configKey)] = item.configValue == null ? '' : String(item.configValue)
      })
    })
    if (!grouped.value[activeGroup.value]) {
      activeGroup.value = Object.keys(grouped.value)[0] || 'SITE'
    }
  } finally {
    loading.value = false
  }
}

const onSave = async () => {
  saving.value = true
  try {
    await configApi.saveGrouped({ ...values })
    ElMessage.success('保存成功，已清除缓存')
    load()
  } finally {
    saving.value = false
  }
}

onMounted(load)
</script>

<style scoped>
.header-card {
  margin-bottom: 12px;
}
.head {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.head .title {
  font-size: 16px;
  font-weight: 600;
}
.tip {
  margin: 8px 0 0;
  color: #909399;
  font-size: 12px;
  line-height: 1.7;
}
.key-tip {
  width: 100%;
  color: #c0c4cc;
  font-size: 12px;
  line-height: 1.4;
}
.group-list {
  margin: 0;
  padding: 0;
  list-style: none;
}
.group-list li {
  display: flex;
  justify-content: space-between;
  padding: 8px 10px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 13px;
}
.group-list li.active {
  background: #ecf5ff;
  color: #409eff;
}
</style>
