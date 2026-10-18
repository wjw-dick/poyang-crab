<template>
  <ProList title="库存" :api="bizApi.stock" :columns="columns" :fields="fields" :filter-fields="filterFields" />
</template>

<script setup lang="ts">
import ProList, { type Column, type Field } from '@/components/ProList/index.vue'
import { bizApi } from '@/api'

/**
 * 库存管理（T24）：自营 + 批发共用；available 可售 / locked 锁定 / total 总量
 */
const columns: Column[] = [
  { prop: 'skuId', label: 'SKU', lookup: 'productSku', width: 200 },
  { prop: 'warehouse', label: '仓库', width: 140 },
  { prop: 'totalQty', label: '总库存', width: 110 },
  { prop: 'availableQty', label: '可售', width: 110 },
  { prop: 'lockedQty', label: '锁定', width: 110 },
  { prop: 'warnQty', label: '预警值', width: 110 }
]

const fields: Field[] = [
  { prop: 'skuId', label: 'SKU', type: 'select', lookup: 'productSku' },
  { prop: 'warehouse', label: '仓库', side: true },
  { prop: 'totalQty', label: '总库存', type: 'number', side: true },
  { prop: 'availableQty', label: '可售库存', type: 'number', side: true },
  { prop: 'lockedQty', label: '锁定库存', type: 'number', side: true },
  { prop: 'warnQty', label: '预警值', type: 'number', side: true }
]

const filterFields: Field[] = [{ prop: 'skuId', label: 'SKU', type: 'select', lookup: 'productSku' }]
</script>
