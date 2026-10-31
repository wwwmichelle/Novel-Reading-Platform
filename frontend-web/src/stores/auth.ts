import { computed, ref } from 'vue'
import { defineStore } from 'pinia'

import { authApi } from '@/api/auth'
import type { SessionStatus, UserResponse } from '@/types/api'
import { toAppError } from '@/utils/errors'
import { useBookshelfStore } from '@/stores/bookshelf'
import {
  clearSnapshot,
  clearTokens,
  getTokens,
  readSnapshot,
  setTokens,
  writeSnapshot,
} from '@/utils/session'

export const useAuthStore = defineStore('auth', () => {
  const user = ref<UserResponse | null>(null)
  const status = ref<SessionStatus>('unknown')
  const degraded = ref(false)
  const refreshing = ref(false)
  const loading = ref(false)
  let bootstrapPromise: Promise<void> | null = null

  const isLoggedIn = computed(() => status.value === 'authenticated')
  const isAdmin = computed(() => user.value?.role === 'admin')

  function markAuthenticated(nextUser: UserResponse | null) {
    if (nextUser) {
      user.value = nextUser
      writeSnapshot(nextUser)
    }
    status.value = 'authenticated'
    degraded.value = false
    refreshing.value = false
  }

  function markDegraded() {
    degraded.value = true
    refreshing.value = false
  }

  function invalidate() {
    clearTokens()
    clearSnapshot()
    useBookshelfStore().reset()
    user.value = null
    status.value = 'invalidated'
    degraded.value = false
    refreshing.value = false
    bootstrapPromise = null
  }

  async function fetchUser() {
    try {
      const resp = await authApi.me()
      markAuthenticated(resp.data)
      return resp.data
    } catch (error) {
      const appError = toAppError(error)
      if (appError.kind === 'unauthorized') invalidate()
      else markDegraded()
      throw error
    }
  }

  function bootstrap(): Promise<void> {
    if (bootstrapPromise) return bootstrapPromise
    const { access, refresh } = getTokens()
    if (!access && !refresh) {
      clearSnapshot()
      user.value = null
      status.value = 'anonymous'
      return Promise.resolve()
    }
    user.value = readSnapshot()
    status.value = 'authenticated'
    bootstrapPromise = fetchUser()
      .catch(() => undefined)
      .then(() => undefined)
    return bootstrapPromise
  }

  async function login(username: string, password: string) {
    loading.value = true
    try {
      const resp = await authApi.login(username, password)
      setTokens(resp.data.access_token, resp.data.refresh_token)
      useBookshelfStore().reset()
      status.value = 'authenticated'
      await fetchUser()
      bootstrapPromise = Promise.resolve()
    } finally {
      loading.value = false
    }
  }

  async function register(username: string, password: string) {
    loading.value = true
    try {
      await authApi.register(username, password)
    } finally {
      loading.value = false
    }
    await login(username, password)
  }

  async function logout() {
    await authApi.logout()
    useBookshelfStore().reset()
    clearTokens()
    clearSnapshot()
    user.value = null
    status.value = 'anonymous'
    degraded.value = false
    refreshing.value = false
    bootstrapPromise = null
  }

  function syncFromStorage() {
    const { access } = getTokens()
    if (!access) {
      useBookshelfStore().reset()
      user.value = null
      status.value = 'anonymous'
      return
    }
    const snapshot = readSnapshot()
    if (snapshot) user.value = snapshot
    status.value = 'authenticated'
  }

  function markInvalid() {
    invalidate()
  }

  return {
    user,
    status,
    degraded,
    refreshing,
    loading,
    isLoggedIn,
    isAdmin,
    bootstrap,
    fetchUser,
    login,
    register,
    logout,
    syncFromStorage,
    markAuthenticated,
    markDegraded,
    markInvalid,
  }
})
