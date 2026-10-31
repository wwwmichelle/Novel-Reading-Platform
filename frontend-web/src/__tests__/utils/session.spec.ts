import { beforeEach, describe, expect, it } from 'vitest'

import {
  SESSION_KEYS,
  clearSnapshot,
  clearTokens,
  getTokens,
  readSnapshot,
  setTokens,
  writeSnapshot,
} from '@/utils/session'
import type { UserResponse } from '@/types/api'

const user: UserResponse = {
  id: 'u1',
  username: 'tester',
  role: 'user',
  created_at: '2026-01-01T00:00:00Z',
}

describe('SESSION_KEYS', () => {
  it('keeps the frozen storage key names', () => {
    expect(SESSION_KEYS).toEqual({
      access: 'access_token',
      refresh: 'refresh_token',
      user: 'session_user',
    })
  })
})

describe('token storage', () => {
  beforeEach(() => localStorage.clear())

  it('returns nulls when nothing is stored', () => {
    expect(getTokens()).toEqual({ access: null, refresh: null })
  })

  it('writes and reads both tokens', () => {
    setTokens('access-1', 'refresh-1')
    expect(getTokens()).toEqual({ access: 'access-1', refresh: 'refresh-1' })
    expect(localStorage.getItem('access_token')).toBe('access-1')
  })

  it('clears tokens and snapshot together', () => {
    setTokens('access-1', 'refresh-1')
    writeSnapshot(user)
    clearTokens()
    expect(getTokens()).toEqual({ access: null, refresh: null })
    expect(readSnapshot()).toBeNull()
  })
})

describe('session snapshot', () => {
  beforeEach(() => localStorage.clear())

  it('writes and reads a snapshot', () => {
    writeSnapshot(user)
    expect(readSnapshot()?.username).toBe('tester')
  })

  it('returns null for malformed json without throwing', () => {
    localStorage.setItem('session_user', '{broken')
    expect(() => readSnapshot()).not.toThrow()
    expect(readSnapshot()).toBeNull()
  })

  it('discards snapshots with an unsupported schema version', () => {
    localStorage.setItem(
      'session_user',
      JSON.stringify({ schemaVersion: 2, savedAt: 'x', user }),
    )
    expect(readSnapshot()).toBeNull()
  })

  it('clears the snapshot explicitly', () => {
    writeSnapshot(user)
    clearSnapshot()
    expect(localStorage.getItem('session_user')).toBeNull()
  })
})