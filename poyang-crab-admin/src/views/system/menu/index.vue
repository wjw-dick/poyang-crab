<template>
  <div class="menu-editor">
    <el-card shadow="never" class="toolbar-card">
      <div class="toolbar">
        <el-radio-group v-model="platform" @change="load">
          <el-radio-button v-for="item in platforms" :key="item.value" :value="item.value">{{ item.label }}</el-radio-button>
        </el-radio-group>
        <div class="spacer" />
        <el-button @click="load">刷新</el-button>
        <el-button type="primary" @click="openCreate(0)">新增根菜单</el-button>
        <template v-if="platform === 'WECHAT_MP'">
          <el-button @click="onWxPreview">预览到微信</el-button>
          <el-button type="success" @click="onWxPublish">发布</el-button>
        </template>
      </div>
    </el-card>

    <!-- 左菜单树 + 右属性面板 + 实时预览（手机/PC 外壳模拟） -->
    <div class="editor-body">
      <el-card shadow="never" class="tree-card">
        <el-tree
          ref="treeRef"
          :data="tree"
          node-key="id"
          default-expand-all
          draggable
          :props="{ label: 'menuName', children: 'children' }"
          @node-click="onNodeClick"
          @node-drop="onDrop"
        >
          <template #default="{ data }">
            <span class="tree-node">
              <el-icon v-if="resolveIcon(data.icon)"><component :is="resolveIcon(data.icon)" /></el-icon>
              <span>{{ data.menuName }}</span>
              <el-tag v-if="data.perm" size="small" type="info">{{ data.perm }}</el-tag>
            </span>
          </template>
        </el-tree>
      </el-card>

      <el-card shadow="never" class="prop-card">
        <template #header>属性面板</template>
        <el-form v-if="current" label-width="100px">
          <el-form-item label="菜单名称"><el-input v-model="current.menuName" /></el-form-item>
          <el-form-item label="上级菜单">
            <el-tree-select
              v-model="current.parentId"
              :data="[{ id: 0, menuName: '顶级菜单', children: tree }]"
              :props="{ label: 'menuName', children: 'children', value: 'id' }"
              node-key="id"
              check-strictly
              style="width: 100%"
            />
          </el-form-item>
          <el-form-item label="平台">
            <el-select v-model="current.platform" style="width: 100%">
              <el-option v-for="item in platforms" :key="item.value" :label="item.label" :value="item.value" />
            </el-select>
          </el-form-item>
          <el-form-item label="类型">
            <el-select v-model="current.menuType" style="width: 100%">
              <el-option v-for="opt in menuTypeOptions" :key="opt.value" :label="opt.label" :value="opt.value" />
            </el-select>
          </el-form-item>
          <el-form-item label="链接类型">
            <el-select v-model="current.linkType" style="width: 100%">
              <el-option v-for="opt in linkTypeOptions" :key="opt.value" :label="opt.label" :value="opt.value" />
            </el-select>
          </el-form-item>
          <el-form-item label="路径"><el-input v-model="current.path" placeholder="/system/config" /></el-form-item>
          <el-form-item label="组件"><el-input v-model="current.component" placeholder="system/config/index" /></el-form-item>
          <el-form-item label="图标">
            <el-select v-model="current.icon" filterable clearable style="width: 100%">
              <el-option v-for="name in icons" :key="name" :label="name" :value="name">
                <el-icon><component :is="name" /></el-icon>
                <span style="margin-left: 6px">{{ name }}</span>
              </el-option>
            </el-select>
          </el-form-item>
          <el-form-item label="权限标识"><el-input v-model="current.perm" placeholder="product:edit" /></el-form-item>
          <el-form-item label="排序"><el-input-number v-model="current.sort" :min="0" /></el-form-item>
          <el-form-item label="是否显示"><el-switch v-model="current.visible" :active-value="1" :inactive-value="0" /></el-form-item>
          <el-form-item>
            <el-button type="primary" @click="onSave">保存</el-button>
            <el-button @click="openCreate(current.id ?? 0)">新增子菜单</el-button>
            <el-button type="danger" @click="onDelete">删除</el-button>
          </el-form-item>
        </el-form>
        <el-empty v-else description="请选择左侧菜单节点" />
      </el-card>

      <el-card shadow="never" class="preview-card">
        <template #header>实时预览</template>
        <!-- 手机外壳（小程序 tabBar / 公众号菜单） -->
        <div v-if="platform === 'MINIAPP' || platform === 'WECHAT_MP'" class="phone-shell">
          <div class="phone-screen">
            <div class="phone-title">{{ platform === 'MINIAPP' ? '小程序' : '公众号' }}</div>
            <div class="phone-menu">
              <div v-for="node in tree.slice(0, 5)" :key="node.id" class="phone-menu-item">{{ node.menuName }}</div>
            </div>
            <div class="phone-tabbar">
              <span v-for="node in tree.slice(0, 4)" :key="node.id">{{ node.menuName }}</span>
            </div>
          </div>
        </div>
        <!-- PC 外壳（导航） -->
        <div v-else class="pc-shell">
          <div class="pc-nav">
            <span v-for="node in tree" :key="node.id">{{ node.menuName }}</span>
          </div>
          <div class="pc-body">导航由后台菜单配置驱动，非写死</div>
        </div>
        <pre v-if="wxPreview" class="wx-preview">{{ wxPreview }}</pre>
      </el-card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import * as ElementPlusIcons from '@element-plus/icons-vue'
import { bizApi, menuApi } from '@/api'
import { dictOptions, loadDicts } from '@/composables/useDict'

/**
 * T10 菜单可视化维护：菜单树 CRUD + 拖拽排序 + 图标选择 + 权限标识 + 实时预览
 * 公众号菜单：预览到微信 → 发布（两步）
 */

/** 图标名列表：必须取组件名的字符串（直接遍历命名空间拿到的是组件对象，选项会全部失效） */
const icons = Object.keys(ElementPlusIcons)
/** 兼容后端已存的小写图标名（tools / menu），按名称不区分大小写回落到正确的组件名 */
const iconNameMap = new Map(icons.map((name) => [name.toLowerCase(), name]))
const resolveIcon = (name?: string) => (name ? iconNameMap.get(name.toLowerCase()) : undefined)
/** 平台 / 菜单类型 / 链接类型统一取字典（系统管理 → 字典管理），页面不再硬编码枚举 */
const platforms = computed(() => dictOptions('platform'))
const menuTypeOptions = computed(() => dictOptions('menu_type'))
const linkTypeOptions = computed(() => dictOptions('link_type'))
const platform = ref('ADMIN')

/** 菜单节点（与后端 t_sys_menu 字段对齐） */
type MenuNode = {
  id?: number
  parentId?: number
  menuName?: string
  platform?: string
  menuType?: string
  linkType?: string
  path?: string
  component?: string
  icon?: string
  perm?: string
  sort?: number
  visible?: number
  keepAlive?: number
  children?: MenuNode[]
}

const tree = ref<MenuNode[]>([])
const current = ref<MenuNode | null>(null)
const wxPreview = ref('')

const load = async () => {
  tree.value = (await menuApi.tree(platform.value)) as unknown as MenuNode[]
  current.value = null
}
const onNodeClick = (node: MenuNode) => {
  current.value = { ...node }
}

const openCreate = (parentId: number) => {
  current.value = {
    parentId,
    menuName: '',
    platform: platform.value,
    menuType: 'MENU',
    linkType: 'INNER',
    path: '',
    component: '',
    icon: '',
    perm: '',
    sort: 0,
    visible: 1,
    keepAlive: 1
  }
}

const onSave = async () => {
  if (!current.value?.menuName) {
    ElMessage.warning('请填写菜单名称')
    return
  }
  if (current.value.id) {
    await bizApi.menu.update(current.value)
  } else {
    await bizApi.menu.create(current.value)
  }
  ElMessage.success('保存成功')
  load()
}

const onDelete = async () => {
  if (!current.value?.id) return
  await ElMessageBox.confirm('删除菜单会同时影响对应端导航展示，确认删除？', '危险操作', {
    type: 'warning',
    confirmButtonText: '确认删除',
    confirmButtonClass: 'el-button--danger'
  })
  await bizApi.menu.remove(current.value.id as number)
  ElMessage.success('删除成功')
  load()
}

/** 拖拽排序：整树提交后重排 */
const onDrop = async () => {
  const nodes: Array<Record<string, unknown>> = []
  const walk = (list: MenuNode[], parentId: number) => {
    list.forEach((node, index) => {
      nodes.push({ id: node.id, parentId, sort: index + 1 })
      if (node.children?.length) walk(node.children, node.id ?? 0)
    })
  }
  walk(tree.value, 0)
  await menuApi.dragSort(nodes)
  ElMessage.success('排序已保存')
  load()
}

const onWxPreview = async () => {
  wxPreview.value = await menuApi.wxPreview()
  ElMessage.success('已生成公众号菜单预览')
}

const onWxPublish = async () => {
  await ElMessageBox.confirm('发布后立即生效于公众号，确认发布？', '发布确认', {
    type: 'warning',
    confirmButtonText: '确认发布'
  })
  await menuApi.wxPublish()
  ElMessage.success('已发布到微信')
  load()
}

onMounted(async () => {
  await loadDicts()
  load()
})
</script>

<style scoped>
.toolbar-card {
  margin-bottom: 12px;
}
.toolbar {
  display: flex;
  align-items: center;
  gap: 8px;
}
.spacer {
  flex: 1;
}
.editor-body {
  display: flex;
  gap: 12px;
  align-items: flex-start;
}
.tree-card {
  width: 340px;
  min-height: 520px;
}
.prop-card {
  flex: 1;
  min-width: 320px;
}
.preview-card {
  width: 300px;
}
.tree-node {
  display: flex;
  align-items: center;
  gap: 6px;
}
.phone-shell {
  display: flex;
  justify-content: center;
}
.phone-screen {
  width: 220px;
  height: 420px;
  border: 10px solid #1f2937;
  border-radius: 24px;
  padding: 10px;
  display: flex;
  flex-direction: column;
  background: #f9fafb;
}
.phone-title {
  text-align: center;
  font-size: 12px;
  color: #6b7280;
  margin-bottom: 8px;
}
.phone-menu {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 6px;
}
.phone-menu-item {
  background: #fff;
  border-radius: 6px;
  padding: 8px 10px;
  font-size: 12px;
}
.phone-tabbar {
  display: flex;
  justify-content: space-around;
  border-top: 1px solid #e5e7eb;
  padding-top: 6px;
  font-size: 11px;
  color: #6b7280;
}
.pc-shell {
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  overflow: hidden;
}
.pc-nav {
  display: flex;
  gap: 14px;
  padding: 10px 12px;
  background: #1f2937;
  color: #e5e7eb;
  font-size: 12px;
}
.pc-body {
  padding: 40px 12px;
  text-align: center;
  color: #9ca3af;
  font-size: 12px;
}
.wx-preview {
  margin-top: 12px;
  max-height: 200px;
  overflow: auto;
  background: #0f172a;
  color: #a7f3d0;
  font-size: 11px;
  padding: 8px;
  border-radius: 6px;
}
</style>
