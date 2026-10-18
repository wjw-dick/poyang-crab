<template>
  <ProList title="支付流水" :api="bizApi.payment" :columns="columns" :fields="fields" :filter-fields="filterFields" />
</template>

<script setup lang="ts">
import ProList, { type Column, type Field } from '@/components/ProList/index.vue'
import { bizApi } from '@/api'

/**
 * T21 支付流水：微信支付 / 支付宝回调落库记录（订单号、第三方交易号、状态、退款金额）
 * 支付回调由 WxPayNotifyController 写入，后台侧只做查询与人工对账
 */
const columns: Column[] = [
  { prop: 'payNo', label: '支付单号', width: 200 },
  { prop: 'orderNo', label: '订单号', width: 200 },
  { prop: 'payType', label: '支付方式', type: 'tag', dict: 'pay_type', width: 110 },
  { prop: 'tradeNo', label: '第三方交易号', width: 200, showOverflowTooltip: true },
  { prop: 'amount', label: '支付金额', type: 'money', width: 120 },
  { prop: 'refundAmount', label: '退款金额', type: 'money', width: 120 },
  { prop: 'payStatus', label: '状态', type: 'tag', dict: 'payment_status', width: 110 },
  { prop: 'payTime', label: '支付时间', width: 170 }
]

const fields: Field[] = [
  { prop: 'payNo', label: '支付单号' },
  { prop: 'orderNo', label: '订单号' },
  { prop: 'payType', label: '支付方式', type: 'select', dict: 'pay_type' },
  { prop: 'tradeNo', label: '第三方交易号', side: true },
  { prop: 'amount', label: '支付金额', type: 'number', side: true },
  { prop: 'refundAmount', label: '退款金额', type: 'number', side: true },
  { prop: 'payStatus', label: '支付流水状态', type: 'select', side: true, dict: 'payment_status' },
  { prop: 'payTime', label: '支付时间', type: 'datetime', side: true },
  { prop: 'notifyRaw', label: '回调原文', type: 'textarea', side: true }
]

const filterFields: Field[] = [
  { prop: 'orderNo', label: '订单号' },
  { prop: 'payNo', label: '支付单号' },
  { prop: 'payStatus', label: '状态', type: 'select', dict: 'payment_status' }
]
</script>
