<template>
  <div class="channel-settlement">
    <el-card class="filter-card" shadow="never">
      <div class="filter-head">
        <span class="title">对账结算</span>
        <div>
          <el-tag effect="plain">T30：结算金额与后台佣金数据一致（佣金按比例快照留痕）</el-tag>
          <el-button @click="load">刷新</el-button>
        </div>
      </div>
      <el-form inline>
        <el-form-item label="结算单号"><el-input v-model="query.settleNo" clearable style="width: 200px" /></el-form-item>
        <el-form-item label="状态">
          <!-- 结算单状态取自「字典管理 → 结算单状态」 -->
          <el-select v-model="query.status" clearable placeholder="全部" style="width: 160px">
            <el-option v-for="opt in settleStatusOptions" :key="opt.value" :label="opt.label" :value="opt.value" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="search">查询</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card shadow="never">
      <el-table v-loading="loading" :data="list" stripe border>
        <el-table-column prop="settleNo" label="结算单号" width="200" />
        <el-table-column prop="channelId" label="渠道商" width="150">
          <template #default="{ row }">{{ lookupLabel('channel', row.channelId) }}</template>
        </el-table-column>
        <el-table-column prop="periodStart" label="周期起" width="120" />
        <el-table-column prop="periodEnd" label="周期止" width="120" />
        <el-table-column label="订单额" width="130">
          <template #default="{ row }">¥ {{ row.orderAmount }}</template>
        </el-table-column>
        <el-table-column label="佣金" width="130">
          <template #default="{ row }">¥ {{ row.commissionAmount }}</template>
        </el-table-column>
        <el-table-column label="应结算" width="130">
          <template #default="{ row }">¥ {{ row.settleAmount }}</template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="110">
          <template #default="{ row }">
            <el-tag :type="row.status === 'CONFIRMED' ? 'success' : 'info'" size="small">
              {{ dictLabel('settlement_status', row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="140" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" :disabled="row.status !== 'DRAFT'" @click="confirm(row)">确认结算</el-button>
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
import { computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { bizApi, http } from '@/api'
import { useTable } from '@/composables/useTable'
import { dictLabel, dictOptions, loadDicts } from '@/composables/useDict'
import { loadLookup, lookupLabel } from '@/composables/useLookup'

/**
 * T27/T30 结算：POST /channel/biz/settlement/{settleNo}/confirm
 * 状态走字典（结算单状态），渠道商显示名称
 */
const settleStatusOptions = computed(() => dictOptions('settlement_status'))
const { loading, list, total, query, load, search, onPageChange } = useTable((params) =>
  bizApi.settlement.page(params) as never
)

const confirm = async (row: Record<string, any>) => {
  await ElMessageBox.confirm(`确认结算单 ${row.settleNo}？确认后佣金标记为已结算。`, '结算确认', {
    type: 'warning',
    confirmButtonText: '确认结算'
  })
  await http<void>({ url: `/channel/biz/settlement/${row.settleNo}/confirm`, method: 'post' })
  ElMessage.success('结算已确认')
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
