<template>
  <div class="sys-audit">
    <el-card class="filter-card" shadow="never">
      <div class="filter-head">
        <span class="title">全操作审计日志</span>
        <div>
          <el-tag type="danger" effect="plain">只读：本页不提供新增 / 修改 / 删除</el-tag>
          <el-button link @click="filterVisible = !filterVisible">{{ filterVisible ? '收起筛选' : '展开筛选' }}</el-button>
        </div>
      </div>
      <el-form v-show="filterVisible" inline>
        <el-form-item label="操作人"><el-input v-model="query.username" clearable placeholder="账号" style="width: 160px" /></el-form-item>
        <el-form-item label="模块"><el-input v-model="query.module" clearable placeholder="如 系统参数" style="width: 160px" /></el-form-item>
        <el-form-item label="操作类型">
          <el-select v-model="query.operation" clearable placeholder="全部" style="width: 150px">
            <el-option v-for="item in operations" :key="item" :label="item" :value="item" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="search">查询</el-button>
          <el-button @click="reset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card shadow="never">
      <el-table v-loading="loading" :data="list" stripe border height="calc(100vh - 320px)">
        <el-table-column prop="id" label="ID" width="90" />
        <el-table-column prop="username" label="操作人" width="130" />
        <el-table-column prop="module" label="模块" width="130" />
        <el-table-column prop="operation" label="操作" width="110">
          <template #default="{ row }">
            <el-tag size="small">{{ row.operation }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="requestUri" label="请求地址" show-overflow-tooltip />
        <el-table-column prop="ip" label="IP" width="140" />
        <el-table-column label="结果" width="90">
          <template #default="{ row }">
            <el-tag :type="row.success === 1 ? 'success' : 'danger'" size="small">{{ row.success === 1 ? '成功' : '失败' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="costMs" label="耗时(ms)" width="100" />
        <el-table-column prop="createTime" label="时间" width="170" />
        <el-table-column label="操作" width="90" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="onDetail(row)">详情</el-button>
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

    <el-drawer v-model="detailVisible" title="审计详情（只读）" size="620px">
      <el-descriptions :column="1" border>
        <el-descriptions-item label="操作人">{{ detail.username }}</el-descriptions-item>
        <el-descriptions-item label="模块 / 操作">{{ detail.module }} / {{ detail.operation }}</el-descriptions-item>
        <el-descriptions-item label="方法">{{ detail.method }}</el-descriptions-item>
        <el-descriptions-item label="请求地址">{{ detail.requestUri }}</el-descriptions-item>
        <el-descriptions-item label="IP / UA">{{ detail.ip }} · {{ detail.userAgent }}</el-descriptions-item>
        <el-descriptions-item label="耗时">{{ detail.costMs }} ms</el-descriptions-item>
        <el-descriptions-item label="结果">{{ detail.success === 1 ? '成功' : '失败' }} {{ detail.errorMsg }}</el-descriptions-item>
        <el-descriptions-item label="入参">
          <pre class="param-json">{{ detail.requestParam }}</pre>
        </el-descriptions-item>
      </el-descriptions>
    </el-drawer>
  </div>
</template>

<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { auditApi } from '@/api'

/**
 * T14 全操作审计日志（只读）
 */
const operations = ['CREATE', 'UPDATE', 'DELETE', 'QUERY', 'LOGIN', 'LOGOUT', 'PUBLISH', 'EXPORT']

const { loading, list, total, query, filterVisible, load, search, reset, onPageChange, onSizeChange } = useAuditTable()
const detailVisible = ref(false)
const detail = ref<Record<string, any>>({})

function useAuditTable() {
  const loading = ref(false)
  const list = ref<Array<Record<string, any>>>([])
  const total = ref(0)
  const filterVisible = ref(true)
  const query = reactive<Record<string, any>>({ current: 1, size: 10, username: '', module: '', operation: '' })

  const load = async () => {
    loading.value = true
    try {
      const page = await auditApi.page({ ...query })
      list.value = (page.records as never) || []
      total.value = page.total || 0
    } finally {
      loading.value = false
    }
  }
  const search = () => {
    query.current = 1
    load()
  }
  const reset = () => {
    query.username = ''
    query.module = ''
    query.operation = ''
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
  return { loading, list, total, query, filterVisible, load, search, reset, onPageChange, onSizeChange }
}

const onDetail = async (row: Record<string, any>) => {
  detail.value = (await auditApi.detail(row.id)) as never
  detailVisible.value = true
}

onMounted(load)
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
.param-json {
  margin: 0;
  max-height: 260px;
  overflow: auto;
  background: #0f172a;
  color: #a7f3d0;
  padding: 10px;
  border-radius: 6px;
  font-size: 12px;
}
</style>
