<template>
  <div class="login-page">
    <div class="login-card">
      <div class="brand">
        <h1>螃蟹小公主</h1>
        <p>鄱阳湖湖蟹 · 多端数字化平台后台</p>
      </div>
      <el-form ref="formRef" :model="form" :rules="rules" size="large" @submit.prevent>
        <el-form-item prop="username">
          <el-input v-model="form.username" placeholder="账号" :prefix-icon="User" />
        </el-form-item>
        <el-form-item prop="password">
          <el-input v-model="form.password" type="password" show-password placeholder="密码" :prefix-icon="Lock" @keyup.enter="onSubmit" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" class="submit" :loading="loading" @click="onSubmit">登录</el-button>
        </el-form-item>
      </el-form>
      <p class="tips">默认账号 admin / Admin@123456（上线前请立即修改）</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, type FormInstance, type FormRules } from 'element-plus'
import { Lock, User } from '@element-plus/icons-vue'
import { useUserStore } from '@/store/user'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()
const formRef = ref<FormInstance>()
const loading = ref(false)
const form = reactive({ username: '', password: '' })

const rules: FormRules = {
  username: [{ required: true, message: '请输入账号', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}

const onSubmit = async () => {
  await formRef.value?.validate(async (valid) => {
    if (!valid) return
    loading.value = true
    try {
      await userStore.login({ ...form })
      ElMessage.success('登录成功')
      await router.push((route.query.redirect as string) || '/dashboard')
    } finally {
      loading.value = false
    }
  })
}
</script>

<style scoped>
.login-page {
  height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #0f172a 0%, #1d4ed8 100%);
}
.login-card {
  width: 380px;
  padding: 36px 32px;
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 18px 40px rgba(15, 23, 42, 0.28);
}
.brand h1 {
  margin: 0 0 6px;
  font-size: 24px;
}
.brand p {
  margin: 0 0 24px;
  color: #6b7280;
  font-size: 13px;
}
.submit {
  width: 100%;
}
.tips {
  margin: 4px 0 0;
  font-size: 12px;
  color: #9ca3af;
  text-align: center;
}
</style>
