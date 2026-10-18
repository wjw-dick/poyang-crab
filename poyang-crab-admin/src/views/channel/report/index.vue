<template>
  <div class="channel-report">
    <el-card class="filter-card" shadow="never">
      <div class="filter-head">
        <span class="title">渠道报单审核</span>
        <div>
          <el-tag effect="plain">审核通过后自动生成批发订单（共用库存与订单体系）</el-tag>
          <el-button @click="load">刷新</el-button>
        </div>
      </div>
      <el-form inline>
        <el-form-item label="报单号"><el-input v-model="query.reportNo" clearable style="width: 200px" /></el-form-item>
        <el-form-item label="审核状态">
          <el-select v-model="query.auditStatus" clearable placeholder="全部" style="width: 150px">
            <el-option v-for="opt in auditStatusOptions" :key="opt.value" :label="opt.label" :value="opt.value" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="search">查询</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card shadow="never">
      <el-table v-loading="loading" :data="list" stripe border>
        <el-table-column prop="reportNo" label="报单号" width="200" />
        <el-table-column prop="channelId" label="渠道商" width="150">
          <template #default="{ row }">{{ lookupLabel('channel', row.channelId) }}</template>
        </el-table-column>
        <el-table-column prop="totalQty" label="总件数" width="100" />
        <el-table-column label="报单金额" width="130">
          <template #default="{ row }">¥ {{ row.totalAmount }}</template>
        </el-table-column>
        <el-table-column prop="orderNo" label="生成订单号" width="200" />
        <el-table-column prop="auditStatus" label="审核状态" width="120">
          <template #default="{ row }">
            <el-tag
              :type="row.auditStatus === 'APPROVED' ? 'success' : row.auditStatus === 'REJECTED' ? 'danger' : 'warning'"
              size="small"
            >
              {{ dictLabel('audit_status', row.auditStatus) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="报单时间" width="170" />
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button link type="success" :disabled="row.auditStatus !== 'PENDING'" @click="audit(row, true)">通过</el-button>
            <el-button link type="danger" :disabled="row.auditStatus !== 'PENDING'" @click="audit(row, false)">拒绝</el-button>
          </template>
        </el-table-column>
      </el-table>
      <div class="table-pagination">
        <el-pagination
          background
          layout="total, prev, pager, next"
          :total="total"
          :current-page="Number(query.current)"
          :page-size="Number(query.size)"
          @current-change="onPageChange"
        />
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { bizApi, http } from '@/api'
import { useTable } from '@/composables/useTable'
import { dictLabel, dictOptions, loadDicts } from '@/composables/useDict'
import { loadLookup, lookupLabel } from '@/composables/useLookup'

/**
 * T25/T28 报单审核：POST /channel/biz/report/audit
 * 审核状态走字典（audit_status），渠道商显示名称
 */
const auditStatusOptions = computed(() => dictOptions('audit_status'))
const { loading, list, total, query, load, search, onPageChange } = useTable((params) =>
  bizApi.channelReport.page(params) as never
)

const audit = async (row: Record<string, any>, approved: boolean) => {
  await ElMessageBox.confirm(
    approved ? `确认通过报单 ${row.reportNo} 并生成批发订单？` : `确认拒绝报单 ${row.reportNo}？`,
    approved ? '审核通过' : '危险操作',
    { type: 'warning', confirmButtonText: '确认', confirmButtonClass: approved ? '' : 'el-button--danger' }
  )
  await http<string>({
    url: '/channel/biz/report/audit',
    method: 'post',
    params: { reportNo: row.reportNo, approved, remark: approved ? '后台审核通过' : '后台审核拒绝' }
  })
  ElMessage.success(approved ? '已通过并生成批发订单' : '已拒绝')
  load()
}

onMounted(async () => {
  await Promise.all([loadDicts(), loadLookup('channel')])
  load()
})
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
</style>
