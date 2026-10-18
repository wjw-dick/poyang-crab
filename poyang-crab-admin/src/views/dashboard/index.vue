<template>
  <div class="dashboard">
    <el-row :gutter="16">
      <el-col v-for="card in cards" :key="card.label" :xs="12" :sm="6">
        <el-card shadow="never" class="stat-card">
          <div class="label">{{ card.label }}</div>
          <div class="value">{{ card.value }}</div>
          <div class="tip">{{ card.tip }}</div>
        </el-card>
      </el-col>
    </el-row>

    <el-card shadow="never" class="todo-card">
      <template #header>待办（冷链发货端 / 渠道商）</template>
      <el-table :data="todos" stripe>
        <el-table-column prop="type" label="类型" width="140" />
        <el-table-column prop="content" label="内容" />
        <el-table-column prop="time" label="时间" width="180" />
        <el-table-column label="操作" width="120">
          <template #default="{ row }">
            <el-button link type="primary" @click="$router.push(row.path)">去处理</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'

/**
 * 数据看板：骨架阶段使用占位数据。
 * TODO(T07) 接入后端统计接口（订单数 / 待发货 / 渠道待结算 / 评价待审）
 */
const cards = ref([
  { label: '今日订单', value: '—', tip: '自营 + 批发合计' },
  { label: '待发货', value: '—', tip: '冷链发货端待处理' },
  { label: '渠道待结算', value: '—', tip: '对账结算单（草稿 / 已确认 / 已打款）' },
  { label: '待审评价', value: '—', tip: '含敏感词过滤结果' }
])

const todos = ref<Array<Record<string, string>>>([
  { type: '冷链发货', content: '待分拣订单（鲜活打包核验：公母/重量）', time: '—', path: '/ship/wait' },
  { type: '渠道报单', content: '待审核报单', time: '—', path: '/channel/report' },
  { type: '内容运营', content: '品牌故事 / 捕捞实景 待发布', time: '—', path: '/cms/article' }
])
</script>

<style scoped>
.stat-card {
  margin-bottom: 16px;
}
.stat-card .label {
  color: #6b7280;
  font-size: 13px;
}
.stat-card .value {
  font-size: 26px;
  font-weight: 700;
  margin: 6px 0;
}
.stat-card .tip {
  color: #9ca3af;
  font-size: 12px;
}
.todo-card {
  margin-top: 8px;
}
</style>
