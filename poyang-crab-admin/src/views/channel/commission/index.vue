<template>
  <ProList title="佣金规则" :api="bizApi.commission" :columns="columns" :fields="fields" :filter-fields="filterFields" />
</template>

<script setup lang="ts">
import ProList, { type Column, type Field } from '@/components/ProList/index.vue'
import { bizApi } from '@/api'

/**
 * T27 分销佣金 / 转介绍返佣明细（比例由后台系统参数配置，不写死）
 * commissionType：SALE 分销佣金 / REFERRAL 转介绍返佣 / TEAM 团队级差
 */
const columns: Column[] = [
  { prop: 'commissionNo', label: '佣金单号', width: 200 },
  // 渠道商 / 来源渠道显示名称，不再暴露 id
  { prop: 'channelId', label: '渠道商', lookup: 'channel', width: 150 },
  { prop: 'fromChannelId', label: '来源渠道', lookup: 'channel', width: 150 },
  { prop: 'orderNo', label: '关联订单', width: 200 },
  { prop: 'commissionType', label: '类型', type: 'tag', dict: 'commission_type', width: 120 },
  { prop: 'baseAmount', label: '计佣基数', type: 'money', width: 120 },
  { prop: 'rate', label: '比例(%)', width: 100 },
  { prop: 'amount', label: '佣金金额', type: 'money', width: 120 },
  { prop: 'settleStatus', label: '结算状态', type: 'tag', dict: 'settle_status', width: 110 },
  { prop: 'settleNo', label: '结算单号', width: 200 }
]

const fields: Field[] = [
  { prop: 'commissionNo', label: '佣金单号' },
  // 渠道商 / 来源渠道改为下拉选择
  { prop: 'channelId', label: '渠道商', type: 'select', lookup: 'channel' },
  { prop: 'orderNo', label: '关联订单' },
  { prop: 'commissionType', label: '佣金类型', type: 'select', dict: 'commission_type' },
  { prop: 'fromChannelId', label: '来源渠道', type: 'select', lookup: 'channel', side: true },
  { prop: 'baseAmount', label: '计佣基数', type: 'number', side: true },
  { prop: 'rate', label: '比例(%)', type: 'number', side: true },
  { prop: 'amount', label: '佣金金额', type: 'number', side: true },
  { prop: 'settleStatus', label: '结算状态', type: 'select', side: true, dict: 'settle_status' },
  { prop: 'settleNo', label: '结算单号', side: true }
]

const filterFields: Field[] = [
  { prop: 'commissionNo', label: '佣金单号' },
  { prop: 'orderNo', label: '关联订单' },
  { prop: 'channelId', label: '渠道商', type: 'select', lookup: 'channel' },
  { prop: 'settleStatus', label: '结算状态', type: 'select', dict: 'settle_status' }
]
</script>
