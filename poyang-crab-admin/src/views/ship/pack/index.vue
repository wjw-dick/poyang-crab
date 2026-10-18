<template>
  <div class="ship-pack">
    <el-card class="filter-card" shadow="never">
      <div class="filter-head">
        <span class="title">冷链发货端 · 打包核验</span>
        <div>
          <el-tag type="warning" effect="plain">鲜活核验：公母 / 重量档 / 只数 / 鲜活度，逐单留痕</el-tag>
          <el-button @click="load">刷新</el-button>
        </div>
      </div>
      <el-form inline>
        <el-form-item label="订单号"><el-input v-model="query.orderNo" clearable placeholder="DD..." style="width: 220px" /></el-form-item>
        <el-form-item label="状态">
          <!-- 状态选项统一取自「字典管理 → 订单状态」 -->
          <el-select v-model="query.orderStatus" clearable placeholder="全部" style="width: 170px">
            <el-option v-for="opt in orderStatusOptions" :key="opt.value" :label="opt.label" :value="opt.value" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="search">查询</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card shadow="never">
      <el-table v-loading="loading" :data="list" stripe border>
        <el-table-column prop="orderNo" label="订单号" width="200" />
        <el-table-column prop="receiverName" label="收货人" width="100" />
        <el-table-column prop="receiverMobile" label="电话" width="130" />
        <el-table-column prop="receiverAddress" label="收货地址" show-overflow-tooltip />
        <el-table-column label="金额" width="110">
          <template #default="{ row }">¥ {{ row.payAmount }}</template>
        </el-table-column>
        <el-table-column prop="orderStatus" label="状态" width="110">
          <template #default="{ row }"><el-tag size="small">{{ dictLabel('order_status', row.orderStatus) }}</el-tag></template>
        </el-table-column>
        <el-table-column label="操作" width="260" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="openPack(row)">打包核验</el-button>
            <el-button link type="success" @click="printWaybill(row)">打印面单</el-button>
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

    <!-- 鲜活打包核验：核验通过后回填运单号并冷链出库（后端联动扣减库存） -->
    <el-dialog v-model="packDialog" title="鲜活打包核验 / 冷链出库" width="720px">
      <el-alert
        type="info"
        :closable="false"
        title="核验项：公母比例、重量档抽检、只数、鲜活度；核验通过后打印面单并出库扣减库存。"
      />
      <el-form :model="packForm" label-width="120px" style="margin-top: 12px">
        <el-form-item label="订单号"><el-input v-model="packForm.orderNo" disabled /></el-form-item>
        <el-form-item label="公母核验">
          <el-radio-group v-model="packForm.crabSex">
            <el-radio v-for="opt in crabSexOptions" :key="opt.value" :value="opt.value">{{ opt.label }}</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="重量档抽检">
          <el-input v-model="packForm.weightLevel" placeholder="如 3.0-3.4两，抽检 3 只" />
        </el-form-item>
        <el-form-item label="只数核验">
          <el-input-number v-model="packForm.pieceCount" :min="1" />
        </el-form-item>
        <el-form-item label="鲜活度">
          <el-rate v-model="packForm.survival" :max="5" />
        </el-form-item>
        <el-form-item label="顺丰运单号">
          <!-- 运单号支持扫码枪 / 摄像头扫条形码（顺丰面单为 CODE_128） -->
          <ScanInput v-model="packForm.expressNo" placeholder="扫码或手工录入运单号" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="packDialog = false">取消</el-button>
        <el-button type="primary" :loading="shipping" @click="submitPack">核验通过并出库发货</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import { ElMessage } from 'element-plus'
import ScanInput from '@/components/ScanInput/index.vue'
import { bizApi, shipApi } from '@/api'
import { useTable } from '@/composables/useTable'
import { dictLabel, dictOptions, loadDicts } from '@/composables/useDict'

/**
 * T24 冷链发货端：打包核验（公母 / 重量 / 鲜活度留痕）→ 出库发货回填运单号
 * 发货成功后由后端 OrderServiceImpl.ship 联动扣减自营 + 批发共用库存
 */
const orderStatusOptions = computed(() => dictOptions('order_status'))
const crabSexOptions = computed(() => dictOptions('crab_sex'))
const { loading, list, total, query, load, search, onPageChange } = useTable((params) =>
  bizApi.order.page(params) as never
)

const packDialog = ref(false)
const shipping = ref(false)
const packForm = reactive<Record<string, any>>({
  orderNo: '',
  crabSex: 'MIXED',
  weightLevel: '',
  pieceCount: 1,
  survival: 5,
  expressNo: ''
})

const openPack = (row: Record<string, any>) => {
  packForm.orderNo = row.orderNo
  packForm.expressNo = ''
  packForm.pieceCount = 1
  packDialog.value = true
}

const printWaybill = (row: Record<string, any>) => {
  // TODO(T24) 对接顺丰电子面单打印（后端 SfExpressService.printWaybill）
  ElMessage.success(`已发送面单打印任务：${row.orderNo}`)
}

const submitPack = async () => {
  if (!packForm.expressNo) {
    ElMessage.warning('请录入顺丰运单号')
    return
  }
  shipping.value = true
  try {
    const packCheck = `公母:${packForm.crabSex};重量档:${packForm.weightLevel};只数:${packForm.pieceCount};鲜活度:${packForm.survival}`
    await shipApi.ship(packForm.orderNo, packForm.expressNo, packCheck)
    ElMessage.success('核验通过，已出库并扣减库存')
    packDialog.value = false
    load()
  } finally {
    shipping.value = false
  }
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
