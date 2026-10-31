import { createPinia, setActivePinia } from 'pinia'
import { beforeEach, describe, expect, it, vi } from 'vitest'

vi.mock('@/api/auth', () => ({
  authApi: {
    register: vi.fn(),
    login: vi.fn(),
    refresh: vi.fn(),
    logout: vi.fn().mockResolvedValue(undefined),
    me: vi.fn(),
  },
}))

import { authApi } from '@/api/auth'
import { useAuthStore } from '@/stores/auth'
import { getTokens, setTokens, writeSnapshot } from '@/utils/session'
import type { UserResponse } from '@/types/api'

const mocked = vi.mocked(authApi)

const user: UserResponse = {
  id: 'u1',
  username: 'tester',
  role: 'user',
  created_at: '2026-01-01T00:00:00Z',
}

describe('useAuthStore session state machine', () => {
  beforeEach(() => {
    localStorage.clear()
    setActivePinia(createPinia())
    vi.clearAllMocks()
  })

  it('becomes anonymous without a token', async () => {
    const store = useAuthStore()
    await store.bootstrap()
    expect(store.status).toBe('anonymous')
    expect(store.isLoggedIn).toBe(false)
  })

  it('restores an authenticated session from token and snapshot', async () => {
    setTokens('access-1', 'refresh-1')
    writeSnapshot(user)
    mocked.me.mockResolvedValue({ data: user } as never)

    const store = useAuthStore()
    await store.bootstrap()

    expect(store.status).toBe('authenticated')
    expect(store.user?.username).toBe('tester')
    expect(mocked.me).toHaveBeenCalledTimes(1)
  })

  it('invalidates when /auth/me returns 401', async () => {
    setTokens('access-1', 'refresh-1')
    writeSnapshot(user)
    mocked.me.mockRejectedValue({ response: { status: 401 } })

    const store = useAuthStore()
    await store.bootstrap()

    expect(store.status).toBe('invalidated')
    expect(getTokens().access).toBeNull()
  })

  it('keeps the session degraded on network errors', async () => {
    setTokens('access-1', 'refresh-1')
    writeSnapshot(user)
    mocked.me.mockRejectedValue({ code: 'ERR_NETWORK' })

    const store = useAuthStore()
    await store.bootstrap()

    expect(store.status).toBe('authenticated')
    expect(store.degraded).toBe(true)
    expect(getTokens().access).toBe('access-1')
  })

  it('login stores tokens and loads the current user', async () => {
    mocked.login.mockResolvedValue({
      data: { access_token: 'new-access', refresh_token: 'new-refresh' },
    } as never)
    mocked.me.mockResolvedValue({ data: user } as never)

    const store = useAuthStore()
    await store.login('tester', 'secret')

    expect(getTokens()).toEqual({ access: 'new-access', refresh: 'new-refresh' })
    expect(store.user?.id).toBe('u1')
    expect(store.loading).toBe(false)
  })

  it('logout clears tokens, snapshot and state', async () => {
    setTokens('access-1', 'refresh-1')
    writeSnapshot(user)
    mocked.me.mockResolvedValue({ data: user } as never)
    const store = useAuthStore()
    await store.bootstrap()

    await store.logout()

    expect(store.status).toBe('anonymous')
    expect(store.user).toBeNull()
    expect(getTokens().access).toBeNull()
    expect(localStorage.getItem('session_user')).toBeNull()
  })

  it('syncFromStorage becomes anonymous when another tab cleared tokens', () => {
    setTokens('access-1', 'refresh-1')
    const store = useAuthStore()
    store.syncFromStorage()
    expect(store.status).toBe('authenticated')

    localStorage.removeItem('access_token')
    store.syncFromStorage()
    expect(store.status).toBe('anonymous')
    expect(store.user).toBeNull()
  })
})