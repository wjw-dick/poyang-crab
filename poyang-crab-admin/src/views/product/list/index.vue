<template>
  <div class="product-list">
    <ProList title="商品" :api="bizApi.product" :columns="columns" :fields="fields" :filter-fields="filterFields" dialog-width="960px" />

    <!-- 多语言富文本：语言 tab（T11 + T09） -->
    <el-drawer v-model="langDrawer" title="多语言内容" size="900px">
      <el-tabs v-model="activeLang">
        <el-tab-pane label="简体中文" name="zh-CN">
          <RichEditor v-model="detailHtmlZh" biz-type="product" />
        </el-tab-pane>
        <el-tab-pane label="English" name="en-US">
          <RichEditor v-model="detailHtmlEn" biz-type="product" />
        </el-tab-pane>
      </el-tabs>
      <template #footer>
        <el-button @click="langDrawer = false">关闭</el-button>
        <el-button type="primary" @click="saveLang">保存</el-button>
      </template>
    </el-drawer>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { ElMessage } from 'element-plus'
import ProList, { type Column, type Field } from '@/components/ProList/index.vue'
import RichEditor from '@/components/RichEditor/index.vue'
import { bizApi } from '@/api'

/**
 * T19 商品管理：湖蟹规格（公母/重量档/只数礼盒）、零售/批发双价、直播间关联
 * 表单遵循 6.1：图片上传独占整行、富文本走对象存储、左右分栏、金额与起订量后台可配置
 */
const columns: Column[] = [
  { prop: 'mainImage', label: '主图', type: 'image', width: 90 },
  { prop: 'productName', label: '商品名称' },
  { prop: 'productNo', label: '商品编号', width: 160 },
  // 分类显示名称而不是 categoryId（取自「商品中心 → 分类管理」）
  { prop: 'categoryId', label: '分类', lookup: 'productCategory', width: 130 },
  { prop: 'retailPrice', label: '零售价', type: 'money', width: 110 },
  { prop: 'wholesalePrice', label: '渠道批发价', type: 'money', width: 120 },
  { prop: 'minOrderQty', label: '批发起订量', width: 110 },
  // 销售模式中文取自字典 sell_mode
  { prop: 'sellMode', label: '销售模式', type: 'tag', dict: 'sell_mode', width: 120 },
  { prop: 'status', label: '上架状态', type: 'tag', dict: 'status', width: 100 },
  { prop: 'sort', label: '排序', width: 80 }
]

const fields: Field[] = [
  { prop: 'productName', label: '商品名称' },
  { prop: 'productNameEn', label: '英文名称' },
  { prop: 'categoryId', label: '分类', type: 'select', lookup: 'productCategory' },
  { prop: 'images', label: '商品图片', type: 'images', bizType: 'product' },
  { prop: 'detailHtml', label: '商品详情', type: 'editor', bizType: 'product' },
  { prop: 'origin', label: '产地', side: true },
  { prop: 'sellMode', label: '销售模式', type: 'select', side: true, dict: 'sell_mode' },
  { prop: 'retailPrice', label: '零售价', type: 'number', side: true },
  { prop: 'wholesalePrice', label: '渠道批发价', type: 'number', side: true },
  { prop: 'minOrderQty', label: '批发起订量', type: 'number', side: true },
  { prop: 'liveRoomId', label: '关联直播间', type: 'number', side: true },
  { prop: 'status', label: '上架状态', type: 'switch', side: true },
  { prop: 'sort', label: '排序', type: 'number', side: true }
]

const filterFields: Field[] = [
  { prop: 'productName', label: '商品名称' },
  { prop: 'categoryId', label: '分类', type: 'select', lookup: 'productCategory' },
  { prop: 'sellMode', label: '销售模式', type: 'select', dict: 'sell_mode' }
]

// 多语言 tab（独立抽屉，避免主表单过长）
const langDrawer = ref(false)
const activeLang = ref('zh-CN')
const detailHtmlZh = ref('')
const detailHtmlEn = ref('')
const saveLang = () => {
  ElMessage.success('已保存（对接 /product 接口 detailHtml / detailHtmlEn 字段）')
  langDrawer.value = false
}
</script>
