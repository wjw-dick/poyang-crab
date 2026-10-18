<template>
  <ProList title="卡券" :api="bizApi.coupon" :columns="columns" :fields="fields" :filter-fields="filterFields" />
</template>

<script setup lang="ts">
import ProList, { type Column, type Field } from '@/components/ProList/index.vue'
import { bizApi } from '@/api'

/**
 * T19 会员卡券：优惠券 / 代金券 / 折扣券
 * couponType：CASH 满减 / DISCOUNT 折扣 / GIFT 赠品
 * 库存 = totalQty 发放总量，usedQty 已核销数量
 */
const columns: Column[] = [
  { prop: 'couponName', label: '券名称', width: 180 },
  { prop: 'couponType', label: '类型', type: 'tag', dict: 'coupon_type', width: 100 },
  { prop: 'threshold', label: '使用门槛', type: 'money', width: 120 },
  { prop: 'discountAmount', label: '抵扣金额', type: 'money', width: 120 },
  { prop: 'discountRate', label: '折扣', width: 90 },
  { prop: 'totalQty', label: '发放总量', width: 110 },
  { prop: 'usedQty', label: '已核销', width: 100 },
  { prop: 'validStart', label: '生效时间', width: 170 },
  { prop: 'validEnd', label: '失效时间', width: 170 },
  { prop: 'status', label: '状态', type: 'tag', dict: 'status', width: 90 }
]

const fields: Field[] = [
  { prop: 'couponName', label: '券名称' },
  { prop: 'couponType', label: '券类型', type: 'select', dict: 'coupon_type' },
  { prop: 'threshold', label: '使用门槛', type: 'number', side: true },
  { prop: 'discountAmount', label: '抵扣金额', type: 'number', side: true },
  { prop: 'discountRate', label: '折扣率(%)', type: 'number', side: true },
  { prop: 'totalQty', label: '发放总量', type: 'number', side: true },
  { prop: 'usedQty', label: '已核销数量', type: 'number', side: true },
  { prop: 'validStart', label: '生效时间', type: 'datetime', side: true },
  { prop: 'validEnd', label: '失效时间', type: 'datetime', side: true },
  { prop: 'status', label: '启用', type: 'switch', side: true }
]

const filterFields: Field[] = [
  { prop: 'couponName', label: '券名称' },
  { prop: 'couponType', label: '券类型', type: 'select', dict: 'coupon_type' }
]
</script>
