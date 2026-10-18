<template>
  <ProList title="栏目" :api="bizApi.category" :columns="columns" :fields="fields" :filter-fields="filterFields" />
</template>

<script setup lang="ts">
import ProList, { type Column, type Field } from '@/components/ProList/index.vue'
import { bizApi } from '@/api'

/**
 * T15 内容栏目：品牌故事 / 养殖基地 / 捕捞实景 等落地页栏目
 * categoryNameEn 与多语言词条配合，供 PC 官网中英双语切换
 */
const columns: Column[] = [
  { prop: 'categoryName', label: '栏目名称', width: 180 },
  { prop: 'categoryNameEn', label: '英文名称', width: 180 },
  { prop: 'categoryCode', label: '栏目编码', width: 160 },
  // 上级栏目显示名称，0 为顶级
  { prop: 'parentId', label: '上级栏目', lookup: 'cmsCategory', lookupEmpty: '顶级', width: 140 },
  { prop: 'sort', label: '排序', width: 90 },
  { prop: 'status', label: '状态', type: 'tag', dict: 'status', width: 90 },
  { prop: 'createTime', label: '创建时间', width: 170 }
]

const fields: Field[] = [
  { prop: 'categoryName', label: '栏目名称' },
  { prop: 'categoryNameEn', label: '英文名称' },
  { prop: 'categoryCode', label: '栏目编码' },
  // 上级栏目下拉；不选默认 0（顶级）
  { prop: 'parentId', label: '上级栏目', type: 'select', lookup: 'cmsCategory', lookupTop: '顶级（不选）', side: true },
  { prop: 'sort', label: '排序', type: 'number', side: true },
  { prop: 'status', label: '启用', type: 'switch', side: true }
]

const filterFields: Field[] = [
  { prop: 'categoryName', label: '栏目名称' },
  { prop: 'categoryCode', label: '栏目编码' }
]
</script>
