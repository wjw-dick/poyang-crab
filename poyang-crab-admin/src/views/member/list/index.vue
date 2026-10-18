<template>
  <ProList title="会员" :api="bizApi.member" :columns="columns" :fields="fields" :filter-fields="filterFields" />
</template>

<script setup lang="ts">
import ProList, { type Column, type Field } from '@/components/ProList/index.vue'
import { bizApi } from '@/api'

/**
 * T18 会员列表：UnionID 与小程序 / 公众号 / H5 三端互通，一个会员一条档案
 * 积分（points）与储值（balance）为快照值，明细见「积分储值」页
 */
const columns: Column[] = [
  { prop: 'avatar', label: '头像', type: 'image', width: 80 },
  { prop: 'nickname', label: '昵称', width: 140 },
  { prop: 'mobile', label: '手机号', width: 130 },
  { prop: 'unionId', label: 'UnionID', width: 200, showOverflowTooltip: true },
  { prop: 'channelId', label: '绑定渠道', lookup: 'channel', width: 140 },
  { prop: 'memberLevel', label: '等级', type: 'tag', dict: 'member_level', width: 110 },
  { prop: 'points', label: '积分', width: 100 },
  { prop: 'balance', label: '储值余额', type: 'money', width: 120 },
  { prop: 'status', label: '状态', type: 'tag', dict: 'status', width: 90 },
  { prop: 'createTime', label: '注册时间', width: 170 }
]

const fields: Field[] = [
  { prop: 'nickname', label: '昵称' },
  { prop: 'mobile', label: '手机号' },
  { prop: 'unionId', label: 'UnionID' },
  { prop: 'avatar', label: '头像', type: 'images', bizType: 'avatar' },
  { prop: 'openIdMini', label: '小程序 OpenID', side: true },
  { prop: 'openIdMp', label: '公众号 OpenID', side: true },
  { prop: 'openIdH5', label: 'H5 OpenID', side: true },
  { prop: 'memberLevel', label: '会员等级', type: 'select', side: true, dict: 'member_level' },
  { prop: 'gender', label: '性别', type: 'select', side: true, dict: 'gender' },
  { prop: 'points', label: '积分', type: 'number', side: true },
  { prop: 'balance', label: '储值余额', type: 'number', side: true },
  { prop: 'channelId', label: '绑定渠道', type: 'select', side: true, lookup: 'channel' },
  { prop: 'status', label: '启用', type: 'switch', side: true }
]

const filterFields: Field[] = [
  { prop: 'nickname', label: '昵称' },
  { prop: 'mobile', label: '手机号' },
  { prop: 'memberLevel', label: '会员等级', type: 'select', dict: 'member_level' }
]
</script>
