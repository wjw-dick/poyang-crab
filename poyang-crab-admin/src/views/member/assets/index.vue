<template>
  <div class="member-assets">
    <el-card shadow="never" class="tips-card">
      <span class="tips">
        积分与储值为会员资产台账：此处按流水核对，余额快照见「会员列表」页。
        积分规则与储值赠送比例在「系统参数 → 业务规则」中配置。
      </span>
    </el-card>

    <el-tabs v-model="tab">
      <el-tab-pane label="积分明细" name="POINT">
        <ProList
          v-if="tab === 'POINT'"
          title="积分流水"
          :api="bizApi.pointLog"
          :columns="pointColumns"
          :fields="pointFields"
          :filter-fields="pointFilters"
        />
      </el-tab-pane>
      <el-tab-pane label="储值明细" name="BALANCE">
        <ProList
          v-if="tab === 'BALANCE'"
          title="储值流水"
          :api="bizApi.balanceLog"
          :columns="balanceColumns"
          :fields="balanceFields"
          :filter-fields="balanceFilters"
        />
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import ProList, { type Column, type Field } from '@/components/ProList/index.vue'
import { bizApi } from '@/api'

/**
 * T19 会员积分 / 储值：分别对应 t_member_point_log 与 t_member_balance_log
 * 两类变更：EARN 增加 / CONSUME 消费 / REFUND 退回 / ADMIN 人工调整
 */
const tab = ref('POINT')

const pointColumns: Column[] = [
  { prop: 'memberId', label: '会员', lookup: 'member', width: 140 },
  { prop: 'changeType', label: '变动类型', type: 'tag', dict: 'change_type', width: 120 },
  { prop: 'points', label: '变动积分', width: 110 },
  { prop: 'beforePoints', label: '变动前', width: 100 },
  { prop: 'afterPoints', label: '变动后', width: 100 },
  { prop: 'source', label: '来源', width: 140 },
  { prop: 'bizNo', label: '业务单号', width: 200 },
  { prop: 'createTime', label: '时间', width: 170 }
]

const pointFields: Field[] = [
  { prop: 'memberId', label: '会员', type: 'select', lookup: 'member' },
  { prop: 'changeType', label: '变动类型', type: 'select', dict: 'change_type' },
  { prop: 'points', label: '变动积分', type: 'number' },
  { prop: 'beforePoints', label: '变动前积分', type: 'number', side: true },
  { prop: 'afterPoints', label: '变动后积分', type: 'number', side: true },
  { prop: 'source', label: '来源', side: true },
  { prop: 'bizNo', label: '业务单号', side: true }
]

const pointFilters: Field[] = [
  { prop: 'memberId', label: '会员', type: 'select', lookup: 'member' },
  { prop: 'changeType', label: '变动类型', type: 'select', dict: 'change_type' }
]

const balanceColumns: Column[] = [
  { prop: 'memberId', label: '会员', lookup: 'member', width: 140 },
  { prop: 'changeType', label: '变动类型', type: 'tag', dict: 'change_type', width: 120 },
  { prop: 'amount', label: '变动金额', type: 'money', width: 120 },
  { prop: 'beforeBalance', label: '变动前', type: 'money', width: 120 },
  { prop: 'afterBalance', label: '变动后', type: 'money', width: 120 },
  { prop: 'bizNo', label: '业务单号', width: 200 },
  { prop: 'createTime', label: '时间', width: 170 }
]

const balanceFields: Field[] = [
  { prop: 'memberId', label: '会员', type: 'select', lookup: 'member' },
  { prop: 'changeType', label: '变动类型', type: 'select', dict: 'change_type' },
  { prop: 'amount', label: '变动金额', type: 'number' },
  { prop: 'beforeBalance', label: '变动前余额', type: 'number', side: true },
  { prop: 'afterBalance', label: '变动后余额', type: 'number', side: true },
  { prop: 'bizNo', label: '业务单号', side: true }
]

const balanceFilters: Field[] = [
  { prop: 'memberId', label: '会员', type: 'select', lookup: 'member' },
  { prop: 'changeType', label: '变动类型', type: 'select', dict: 'change_type' }
]
</script>

<style scoped>
.tips-card {
  margin-bottom: 12px;
}
.tips {
  font-size: 13px;
  color: #6b7280;
}
</style>
