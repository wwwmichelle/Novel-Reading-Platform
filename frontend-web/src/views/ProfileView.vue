<template>
  <div class="profile page">
    <div class="container narrow">
      <div class="profile-card card">
        <div class="avatar">{{ initial }}</div>
        <div class="identity">
          <h2>{{ authStore.user?.username || '读者' }}</h2>
          <span class="role" :class="{ admin: authStore.isAdmin }">
            {{ authStore.isAdmin ? '管理员' : '普通用户' }}
          </span>
        </div>
      </div>

      <div class="info-card card">
        <div class="row">
          <span class="label">用户名</span>
          <span class="value">{{ authStore.user?.username || '-' }}</span>
        </div>
        <div class="row">
          <span class="label">账号角色</span>
          <span class="value">{{ authStore.isAdmin ? '管理员' : '普通用户' }}</span>
        </div>
        <div class="row">
          <span class="label">注册时间</span>
          <span class="value">{{ formatTime(authStore.user?.created_at) }}</span>
        </div>
      </div>

      <button type="button" class="btn btn-danger logout-btn" :disabled="loggingOut" @click="logout">
        {{ loggingOut ? '退出中...' : '退出登录' }}
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { useRouter } from 'vue-router'

import { useAuthStore } from '@/stores/auth'
import { useToast } from '@/composables/useToast'
import { useConfirm } from '@/composables/useConfirm'

const authStore = useAuthStore()
const router = useRouter()
const toast = useToast()
const confirm = useConfirm()
const loggingOut = ref(false)

const initial = computed(() => (authStore.user?.username || '读').trim().charAt(0))

function formatTime(value?: string) {
  if (!value) return '-'
  return new Date(value).toLocaleString('zh-CN')
}

async function logout() {
  const confirmed = await confirm.ask({
    title: '退出登录',
    message: '确定退出当前账号？',
    confirmText: '退出',
    danger: true,
  })
  if (!confirmed) return
  loggingOut.value = true
  try {
    await authStore.logout()
    toast.success('已退出登录')
    router.replace('/login')
  } finally {
    loggingOut.value = false
  }
}
</script>

<style scoped>
.narrow {
  max-width: 480px;
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
}

.profile-card {
  display: flex;
  align-items: center;
  gap: 18px;
  padding: 24px;
  border-radius: var(--radius-lg);
}

.avatar {
  display: grid;
  place-items: center;
  width: 64px;
  height: 64px;
  border-radius: 50%;
  background: linear-gradient(135deg, var(--color-primary), #6f9bff);
  color: #fff;
  font-size: 26px;
  font-weight: 700;
  box-shadow: 0 8px 20px rgba(47, 107, 255, 0.28);
}

.identity h2 {
  font-size: var(--font-lg);
  margin-bottom: 6px;
}

.role {
  display: inline-block;
  padding: 2px 10px;
  border-radius: var(--radius-pill);
  background: var(--color-surface-2);
  color: var(--color-text-2);
  font-size: var(--font-xs);
}

.role.admin {
  background: var(--color-accent-soft);
  color: var(--color-warning);
}

.info-card {
  padding: 8px 24px;
  border-radius: var(--radius-md);
}

.row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px 0;
  border-bottom: 1px solid var(--color-border);
}

.row:last-child {
  border-bottom: none;
}

.label {
  color: var(--color-text-3);
  font-size: var(--font-sm);
}

.value {
  color: var(--color-text);
  font-size: var(--font-sm);
  font-weight: 500;
}

.logout-btn {
  margin-top: 6px;
  min-height: 44px;
  width: 100%;
}
</style>