import type { UserResponse } from '@/types/api'

export const SESSION_KEYS = {
  access: 'access_token',
  refresh: 'refresh_token',
  user: 'session_user',
} as const

const SNAPSHOT_SCHEMA_VERSION = 1

export interface SessionSnapshot {
  schemaVersion: number
  savedAt: string
  user: UserResponse
}

type KeyValueStore = Pick<Storage, 'getItem' | 'setItem' | 'removeItem'>

const memoryStore = new Map<string, string>()
let useMemoryFallback = false

function resolveStorage(): KeyValueStore {
  if (useMemoryFallback) {
    return {
      getItem: (key) => memoryStore.get(key) ?? null,
      setItem: (key, value) => {
        memoryStore.set(key, value)
      },
      removeItem: (key) => {
        memoryStore.delete(key)
      },
    }
  }
  return localStorage
}

function probeStorage() {
  try {
    const probeKey = '__novel_probe__'
    localStorage.setItem(probeKey, '1')
    localStorage.removeItem(probeKey)
    useMemoryFallback = false
  } catch {
    useMemoryFallback = true
  }
}

probeStorage()

export function getTokens() {
  const storage = resolveStorage()
  try {
    return {
      access: storage.getItem(SESSION_KEYS.access),
      refresh: storage.getItem(SESSION_KEYS.refresh),
    }
  } catch {
    return { access: null, refresh: null }
  }
}

export function setTokens(access: string, refresh: string) {
  const storage = resolveStorage()
  try {
    storage.setItem(SESSION_KEYS.access, access)
    storage.setItem(SESSION_KEYS.refresh, refresh)
  } catch {
    useMemoryFallback = true
    memoryStore.set(SESSION_KEYS.access, access)
    memoryStore.set(SESSION_KEYS.refresh, refresh)
  }
}

export function clearTokens() {
  const storage = resolveStorage()
  try {
    storage.removeItem(SESSION_KEYS.access)
    storage.removeItem(SESSION_KEYS.refresh)
  } catch {
    memoryStore.delete(SESSION_KEYS.access)
    memoryStore.delete(SESSION_KEYS.refresh)
  }
  clearSnapshot()
}

export function readSnapshot(): UserResponse | null {
  const storage = resolveStorage()
  try {
    const raw = storage.getItem(SESSION_KEYS.user)
    if (!raw) return null
    const parsed = JSON.parse(raw) as SessionSnapshot
    if (parsed?.schemaVersion !== SNAPSHOT_SCHEMA_VERSION) {
      storage.removeItem(SESSION_KEYS.user)
      return null
    }
    return parsed.user ?? null
  } catch {
    return null
  }
}

export function writeSnapshot(user: UserResponse) {
  const storage = resolveStorage()
  const snapshot: SessionSnapshot = {
    schemaVersion: SNAPSHOT_SCHEMA_VERSION,
    savedAt: new Date().toISOString(),
    user,
  }
  try {
    storage.setItem(SESSION_KEYS.user, JSON.stringify(snapshot))
  } catch {
    useMemoryFallback = true
    memoryStore.set(SESSION_KEYS.user, JSON.stringify(snapshot))
  }
}

export function clearSnapshot() {
  const storage = resolveStorage()
  try {
    storage.removeItem(SESSION_KEYS.user)
  } catch {
    memoryStore.delete(SESSION_KEYS.user)
  }
}