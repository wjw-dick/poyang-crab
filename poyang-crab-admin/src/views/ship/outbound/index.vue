<template>
  <div class="ship-outbound">
    <el-card class="filter-card" shadow="never">
      <div class="filter-head">
        <span class="title">出库发货 · 物流单号回填</span>
        <div>
          <el-button @click="load">刷新</el-button>
        </div>
      </div>
      <el-form inline>
        <el-form-item label="订单号"><el-input v-model="query.orderNo" clearable style="width: 200px" /></el-form-item>
        <el-form-item label="运单号">
          <!-- 凡是「顺丰运单号 / 运单号」都支持扫码录入 -->
          <ScanInput v-model="query.expressNo" placeholder="扫码或输入运单号" style="width: 240px" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="search">查询</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card shadow="never">
      <el-table v-loading="loading" :data="list" stripe border>
        <el-table-column prop="orderNo" label="订单号" width="200" />
        <el-table-column prop="expressCompany" label="承运商" width="110" />
        <el-table-column prop="expressNo" label="运单号" width="200" />
        <el-table-column prop="shipStatus" label="发货状态" width="130">
          <template #default="{ row }">
            <el-tag size="small">{{ dictLabel('ship_status', row.shipStatus) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="packCheck" label="打包核验" show-overflow-tooltip />
        <el-table-column prop="shipTime" label="发货时间" width="170" />
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="openRefill(row)">回填运单号</el-button>
            <el-button link type="primary" @click="queryTrack(row)">查轨迹</el-button>
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

    <el-dialog v-model="dialogVisible" title="回填顺丰运单号" width="520px">
      <el-form :model="form" label-width="110px">
        <el-form-item label="订单号"><el-input v-model="form.orderNo" disabled /></el-form-item>
        <el-form-item label="运单号">
          <ScanInput v-model="form.expressNo" placeholder="扫码或手工录入" />
        </el-form-item>
        <el-form-item label="打包核验"><el-input v-model="form.packCheck" type="textarea" :rows="2" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="save">确认出库</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { ElMessage } from 'element-plus'
import ScanInput from '@/components/ScanInput/index.vue'
import { bizApi, http, shipApi } from '@/api'
import { useTable } from '@/composables/useTable'
import { dictLabel, loadDicts } from '@/composables/useDict'

/**
 * T24 出库发货：物流单号回填 + 轨迹查询（顺丰冷链）
 * 发货成功后库存联动扣减（自营 + 批发共用）
 */
const { loading, list, total, query, load, search, onPageChange } = useTable((params) =>
  bizApi.delivery.page(params) as never
)

const dialogVisible = ref(false)
const saving = ref(false)
const form = reactive<Record<string, any>>({ orderNo: '', expressNo: '', packCheck: '' })

const openRefill = (row: Record<string, any>) => {
  Object.assign(form, { orderNo: row.orderNo, expressNo: row.expressNo || '', packCheck: row.packCheck || '' })
  dialogVisible.value = true
}

const save = async () => {
  saving.value = true
  try {
    await shipApi.ship(form.orderNo, form.expressNo, form.packCheck)
    ElMessage.success('已出库，库存联动扣减完成')
    dialogVisible.value = false
    load()
  } finally {
    saving.value = false
  }
}

const queryTrack = async (row: Record<string, any>) => {
  // TODO(T21) 轨迹查询：接入 GET /logistics/track?expressNo=（SfExpressService#queryRoutes）
  ElMessage.info(`轨迹查询（骨架）：${row.expressNo || row.orderNo}`)
}

onMounted(async () => {
  await loadDicts()
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
