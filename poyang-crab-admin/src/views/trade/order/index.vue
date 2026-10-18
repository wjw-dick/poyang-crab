<template>
  <ProList title="订单" :api="bizApi.order" :columns="columns" :fields="fields" :filter-fields="filterFields" dialog-width="960px" />
</template>

<script setup lang="ts">
import ProList, { type Column, type Field } from '@/components/ProList/index.vue'
import { bizApi } from '@/api'

/**
 * 订单管理（T29 全链路）：自营 + 批发共用；状态流转
 * UNPAID → PAID → SORTING → PACKED → SHIPPED → RECEIVED → COMPLETED
 */
const columns: Column[] = [
  { prop: 'orderNo', label: '订单号', width: 200 },
  { prop: 'bizMode', label: '模式', type: 'tag', dict: 'biz_mode', width: 110 },
  { prop: 'memberId', label: '会员', lookup: 'member', width: 130 },
  { prop: 'channelId', label: '渠道商', lookup: 'channel', width: 130 },
  { prop: 'payAmount', label: '实付', type: 'money', width: 110 },
  { prop: 'orderStatus', label: '订单状态', type: 'tag', dict: 'order_status', width: 110 },
  { prop: 'payStatus', label: '支付状态', type: 'tag', dict: 'pay_status', width: 110 },
  { prop: 'receiverName', label: '收货人', width: 100 },
  { prop: 'source', label: '来源', dict: 'order_source', width: 110 },
  { prop: 'createTime', label: '下单时间', width: 170 }
]

const fields: Field[] = [
  // 订单号支持扫码枪 / 摄像头扫码（条形码）
  { prop: 'orderNo', label: '订单号', type: 'scan', placeholder: '扫码或输入订单号' },
  { prop: 'receiverName', label: '收货人' },
  { prop: 'receiverMobile', label: '联系电话' },
  { prop: 'receiverAddress', label: '收货地址' },
  { prop: 'remark', label: '订单备注', type: 'textarea' },
  { prop: 'bizMode', label: '业务模式', type: 'select', side: true, dict: 'biz_mode' },
  { prop: 'orderStatus', label: '订单状态', type: 'select', side: true, dict: 'order_status' },
  { prop: 'payStatus', label: '支付状态', type: 'select', side: true, dict: 'pay_status' },
  { prop: 'totalAmount', label: '商品金额', type: 'number', side: true },
  { prop: 'freightAmount', label: '冷链运费', type: 'number', side: true },
  { prop: 'payAmount', label: '实付金额', type: 'number', side: true },
  { prop: 'cancelReason', label: '取消原因', type: 'textarea', side: true }
]

const filterFields: Field[] = [
  { prop: 'orderNo', label: '订单号' },
  { prop: 'orderStatus', label: '订单状态', type: 'select', dict: 'order_status' },
  { prop: 'source', label: '来源', type: 'select', dict: 'order_source' }
]
</script>
