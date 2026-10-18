<template>
  <ProList title="收货评价" :api="bizApi.review" :columns="columns" :fields="fields" :filter-fields="filterFields" />
</template>

<script setup lang="ts">
import ProList, { type Column, type Field } from '@/components/ProList/index.vue'
import { bizApi } from '@/api'

/**
 * T21 收货评价审核：内容经敏感词过滤后落库，isShow 控制前台展示
 */
const columns: Column[] = [
  { prop: 'orderNo', label: '订单号', width: 200 },
  // 新增「商品名称」列：按 productId 取商品名，运营不再面对 id
  { prop: 'productId', label: '商品名称', lookup: 'product', width: 180 },
  { prop: 'score', label: '评分', width: 80 },
  { prop: 'survivalRate', label: '鲜活度', width: 90 },
  { prop: 'content', label: '评价内容' },
  { prop: 'isShow', label: '展示', type: 'tag', dict: 'yes_no', width: 80 },
  { prop: 'createTime', label: '时间', width: 170 }
]

const fields: Field[] = [
  { prop: 'orderNo', label: '订单号' },
  { prop: 'content', label: '评价内容', type: 'textarea' },
  { prop: 'images', label: '评价图片', type: 'images', bizType: 'review' },
  { prop: 'score', label: '评分(1-5)', type: 'number', side: true },
  { prop: 'survivalRate', label: '鲜活度(1-5)', type: 'number', side: true },
  { prop: 'isShow', label: '前台展示', type: 'switch', side: true },
  { prop: 'replyContent', label: '商家回复', type: 'textarea', side: true }
]

const filterFields: Field[] = [{ prop: 'orderNo', label: '订单号' }]
</script>
