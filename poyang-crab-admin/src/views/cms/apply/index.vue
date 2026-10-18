<template>
  <ProList title="渠道商申请" :api="bizApi.apply" :columns="columns" :fields="fields" :filter-fields="filterFields" />
</template>

<script setup lang="ts">
import ProList, { type Column, type Field } from '@/components/ProList/index.vue'
import { bizApi } from '@/api'

/**
 * T16 招商：PC 官网渠道商申请表单落地后的审核（来源 /api/portal/channel-apply）
 */
const columns: Column[] = [
  { prop: 'companyName', label: '公司/个人' },
  { prop: 'contactName', label: '联系人', width: 110 },
  { prop: 'contactMobile', label: '联系电话', width: 140 },
  { prop: 'region', label: '区域', width: 140 },
  { prop: 'intention', label: '合作意向', showOverflowTooltip: true },
  { prop: 'auditStatus', label: '审核状态', type: 'tag', dict: 'audit_status', width: 120 },
  { prop: 'createTime', label: '申请时间', width: 170 }
]

const fields: Field[] = [
  { prop: 'companyName', label: '公司/个人' },
  { prop: 'contactName', label: '联系人' },
  { prop: 'contactMobile', label: '联系电话' },
  { prop: 'intention', label: '合作意向', type: 'textarea' },
  { prop: 'region', label: '区域', side: true },
  // 审核状态走字典（audit_status）
  { prop: 'auditStatus', label: '审核状态', type: 'select', side: true, dict: 'audit_status' },
  { prop: 'auditRemark', label: '审核备注', type: 'textarea', side: true }
]

const filterFields: Field[] = [
  { prop: 'contactMobile', label: '联系电话' },
  { prop: 'auditStatus', label: '审核状态', type: 'select', dict: 'audit_status' }
]
</script>
