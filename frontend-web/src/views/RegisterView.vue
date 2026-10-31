<template>
  <div class="auth-shell">
    <section class="auth-visual">
      <div class="brand">
        <span class="brand-mark">书</span>
        <span>小说阅读</span>
      </div>
      <h1>创建账号<br />开启你的阅读旅程</h1>
      <p class="visual-desc">注册后即可加入书架、记录阅读进度，并在任意设备同步。</p>
      <div class="visual-stack" aria-hidden="true">
        <span class="spine s1"></span>
        <span class="spine s2"></span>
        <span class="spine s3"></span>
        <span class="spine s4"></span>
        <span class="spine s5"></span>
      </div>
    </section>

    <section class="auth-panel">
      <div class="register-page card">
        <h2>创建账号</h2>
        <p class="subtitle">只需一步，即可开始阅读</p>
        <form @submit.prevent="handleRegister">
          <label class="field">
            <span>用户名</span>
            <input v-model="username" placeholder="至少 3 个字符" required minlength="3" autocomplete="username" />
          </label>
          <label class="field">
            <span>密码</span>
            <input v-model="password" type="password" placeholder="至少 6 个字符" required minlength="6" autocomplete="new-password" />
          </label>
          <label class="field">
            <span>确认密码</span>
            <input v-model="confirmPassword" type="password" placeholder="请再次输入密码" required minlength="6" autocomplete="new-password" />
          </label>
          <button type="submit" class="btn btn-primary submit" :disabled="authStore.loading">
            {{ authStore.loading ? '注册中...' : '注册并登录' }}
          </button>
          <p v-if="errorMsg" class="error">{{ errorMsg }}</p>
        </form>
        <router-link class="switch" :to="{ name: 'login', query: { redirect: redirectTarget() } }">已有账号？去登录</router-link>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'

import { sanitizeRedirect } from '@/utils/url'
import { useAuthStore } from '@/stores/auth'
import { useToast } from '@/composables/useToast'

const authStore = useAuthStore()
const router = useRouter()
const route = useRoute()
const redirectTarget = () => sanitizeRedirect(route.query.redirect) ?? '/'
const toast = useToast()

const username = ref('')
const password = ref('')
const confirmPassword = ref('')
const errorMsg = ref('')

async function handleRegister() {
  errorMsg.value = ''
  if (password.value !== confirmPassword.value) {
    errorMsg.value = '两次输入的密码不一致'
    return
  }
  try {
    await authStore.register(username.value.trim(), password.value)
    toast.success('注册成功，已自动登录')
    router.replace(redirectTarget())
  } catch (e: any) {
    errorMsg.value = e.response?.data?.message || '注册失败，请稍后重试'
  }
}
</script>

<style scoped src="../styles/auth.css"></style>
