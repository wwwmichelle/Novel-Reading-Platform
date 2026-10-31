<template>
  <div class="auth-shell">
    <section class="auth-visual">
      <div class="brand">
        <span class="brand-mark">书</span>
        <span>小说阅读</span>
      </div>
      <h1>在字里行间<br />遇见另一个世界</h1>
      <p class="visual-desc">登录后可管理书架、同步阅读进度、参与作品评论。</p>
      <div class="visual-stack" aria-hidden="true">
        <span class="spine s1"></span>
        <span class="spine s2"></span>
        <span class="spine s3"></span>
        <span class="spine s4"></span>
        <span class="spine s5"></span>
      </div>
    </section>

    <section class="auth-panel">
      <div class="login-page card">
        <h2>欢迎回来</h2>
        <p class="subtitle">登录后同步书架和阅读进度</p>
        <p v-if="expired" class="error" role="status">登录已过期，请重新登录</p>
        <form @submit.prevent="handleLogin">
          <label class="field">
            <span>用户名</span>
            <input v-model="username" placeholder="请输入用户名" required minlength="3" autocomplete="username" />
          </label>
          <label class="field">
            <span>密码</span>
            <input v-model="password" type="password" placeholder="请输入密码" required autocomplete="current-password" />
          </label>
          <button type="submit" class="btn btn-primary submit" :disabled="authStore.loading">
            {{ authStore.loading ? '登录中...' : '登录' }}
          </button>
          <p v-if="errorMsg" class="error">{{ errorMsg }}</p>
        </form>
        <router-link class="switch" to="/">返回首页</router-link>
        <router-link class="switch" :to="{ name: 'register', query: { redirect: redirectTarget() } }">没有账号？去注册</router-link>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'

import { useAuthStore } from '@/stores/auth'
import { useToast } from '@/composables/useToast'
import { sanitizeRedirect } from '@/utils/url'

const authStore = useAuthStore()
const route = useRoute()
const router = useRouter()
const toast = useToast()

const username = ref('')
const password = ref('')
const errorMsg = ref('')

const expired = computed(() => route.query.reason === 'expired')

function redirectTarget(): string {
  return sanitizeRedirect(route.query.redirect) ?? '/'
}

async function handleLogin() {
  errorMsg.value = ''
  try {
    await authStore.login(username.value.trim(), password.value)
    toast.success('登录成功')
    router.replace(redirectTarget())
  } catch (e: any) {
    errorMsg.value = e.response?.data?.message || '登录失败，请检查账号或密码'
  }
}
</script>

<style scoped src="../styles/auth.css"></style>
