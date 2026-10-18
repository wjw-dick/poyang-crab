<template>
  <ProList title="商品分类" :api="bizApi.productCategory" :columns="columns" :fields="fields" :filter-fields="filterFields" />
</template>

<script setup lang="ts">
import ProList, { type Column, type Field } from '@/components/ProList/index.vue'
import { bizApi } from '@/api'

const columns: Column[] = [
  { prop: 'categoryName', label: '分类名称' },
  { prop: 'categoryNameEn', label: '英文名称' },
  // 上级分类显示名称，0 视为顶级
  { prop: 'parentId', label: '上级分类', lookup: 'productCategory', lookupEmpty: '顶级', width: 140 },
  { prop: 'icon', label: '图标', type: 'image', width: 90 },
  { prop: 'sort', label: '排序', width: 90 },
  { prop: 'status', label: '状态', type: 'tag', dict: 'status', width: 90 }
]

const fields: Field[] = [
  { prop: 'categoryName', label: '分类名称' },
  { prop: 'categoryNameEn', label: '英文名称' },
  { prop: 'icon', label: '图标' },
  // 上级分类下拉；不选默认 0（顶级）
  { prop: 'parentId', label: '上级分类', type: 'select', lookup: 'productCategory', lookupTop: '顶级（不选）', side: true },
  { prop: 'sort', label: '排序', type: 'number', side: true },
  { prop: 'status', label: '启用', type: 'switch', side: true }
]

const filterFields: Field[] = [{ prop: 'categoryName', label: '分类名称' }]
</script>
