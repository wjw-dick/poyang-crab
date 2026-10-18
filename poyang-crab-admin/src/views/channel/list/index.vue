<template>
  <ProList title="渠道商" :api="bizApi.channel" :columns="columns" :fields="fields" :filter-fields="filterFields" dialog-width="960px" />
</template>

<script setup lang="ts">
import ProList, { type Column, type Field } from '@/components/ProList/index.vue'
import { bizApi } from '@/api'

/**
 * T28 渠道档案：分销/佣金规则配置（比例后台可配置，落库留痕）
 * 下级经销商通过 parentId 组成渠道树（见 /channel/relation）
 */
const columns: Column[] = [
  { prop: 'channelNo', label: '渠道编号', width: 170 },
  { prop: 'channelName', label: '渠道名称' },
  { prop: 'contactName', label: '联系人', width: 100 },
  { prop: 'contactMobile', label: '联系电话', width: 130 },
  // 上级渠道显示名称，0 为顶级
  { prop: 'parentId', label: '上级渠道', lookup: 'channel', lookupEmpty: '顶级', width: 140 },
  { prop: 'channelLevel', label: '等级', type: 'tag', dict: 'channel_level', width: 100 },
  { prop: 'commissionRate', label: '分销佣金(%)', width: 130 },
  { prop: 'referralRate', label: '转介绍返佣(%)', width: 140 },
  { prop: 'creditQuota', label: '授信额度', width: 120 },
  { prop: 'usedQuota', label: '已用额度', width: 120 },
  { prop: 'status', label: '状态', type: 'tag', dict: 'channel_status', width: 110 }
]

const fields: Field[] = [
  { prop: 'channelName', label: '渠道名称' },
  { prop: 'contactName', label: '联系人' },
  { prop: 'contactMobile', label: '联系电话' },
  { prop: 'licenseImages', label: '资质证件', type: 'images', bizType: 'channel' },
  { prop: 'channelNo', label: '渠道编号', side: true },
  { prop: 'channelLevel', label: '渠道等级', type: 'select', side: true, dict: 'channel_level' },
  // 上级渠道下拉；不选即 0（顶级渠道）
  { prop: 'parentId', label: '上级渠道', type: 'select', lookup: 'channel', lookupTop: '顶级（不选）', side: true },
  { prop: 'commissionRate', label: '分销佣金比例(%)', type: 'number', side: true },
  { prop: 'referralRate', label: '转介绍返佣比例(%)', type: 'number', side: true },
  { prop: 'creditQuota', label: '授信额度', type: 'number', side: true },
  { prop: 'usedQuota', label: '已用额度', type: 'number', side: true },
  { prop: 'status', label: '审核状态', type: 'select', side: true, dict: 'channel_status' }
]

const filterFields: Field[] = [
  { prop: 'channelName', label: '渠道名称' },
  { prop: 'status', label: '状态', type: 'select', dict: 'channel_status' }
]
</script>
