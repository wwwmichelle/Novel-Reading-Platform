import axios, { AxiosError, type AxiosAdapter, type InternalAxiosRequestConfig } from 'axios'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'

import { request, setTokens } from '@/api/request'
import { getTokens } from '@/utils/session'

const originalAdapter = request.defaults.adapter

function ok(config: InternalAxiosRequestConfig) {
  return {
    data: { ok: true },
    status: 200,
    statusText: 'OK',
    headers: {},
    config,
  }
}

function httpError(status: number, config: InternalAxiosRequestConfig, code = 'ERR_BAD_RESPONSE') {
  return new AxiosError(
    `failed ${status}`,
    code,
    config,
    null,
    {
      status,
      statusText: '',
      data: { message: 'x' },
      headers: {},
      config,
    } as never,
  )
}

function refreshOk() {
  return { data: { access_token: 'new-access', refresh_token: 'new-refresh' } }
}

describe('request interceptor', () => {
  beforeEach(() => {
    localStorage.clear()
    vi.restoreAllMocks()
  })

  afterEach(() => {
    request.defaults.adapter = originalAdapter
  })

  it('refreshes once and replays the original request on 401', async () => {
    setTokens('old-access', 'old-refresh')
    let calls = 0
    request.defaults.adapter = (async (config: InternalAxiosRequestConfig) => {
      calls += 1
      if (calls === 1) throw httpError(401, config)
      return ok(config)
    }) as AxiosAdapter
    const post = vi.spyOn(axios, 'post').mockResolvedValue(refreshOk() as never)

    const resp = await request.get('/api/v1/books')

    expect(resp.data).toEqual({ ok: true })
    expect(post).toHaveBeenCalledTimes(1)
    expect(getTokens().access).toBe('new-access')
  })

  it('deduplicates refresh across three concurrent 401 responses', async () => {
    setTokens('old-access', 'old-refresh')
    request.defaults.adapter = (async (config: InternalAxiosRequestConfig) => {
      if (config.headers?.Authorization === 'Bearer new-access') return ok(config)
      throw httpError(401, config)
    }) as AxiosAdapter
    const post = vi.spyOn(axios, 'post').mockResolvedValue(refreshOk() as never)

    const results = await Promise.all([
      request.get('/api/v1/books'),
      request.get('/api/v1/categories'),
      request.get('/api/v1/bookshelf'),
    ])

    expect(results).toHaveLength(3)
    expect(post).toHaveBeenCalledTimes(1)
  })

  it('rejects as unauthorized when the replay also returns 401', async () => {
    setTokens('old-access', 'old-refresh')
    request.defaults.adapter = (async (config: InternalAxiosRequestConfig) => {
      throw httpError(401, config)
    }) as AxiosAdapter
    const post = vi.spyOn(axios, 'post').mockResolvedValue(refreshOk() as never)

    await expect(request.get('/api/v1/books')).rejects.toMatchObject({
      appError: { kind: 'unauthorized' },
    })
    expect(post).toHaveBeenCalledTimes(1)
  })

  it('keeps tokens on network errors', async () => {
    setTokens('old-access', 'old-refresh')
    request.defaults.adapter = (async (config: InternalAxiosRequestConfig) => {
      throw new AxiosError('network down', 'ERR_NETWORK', config)
    }) as AxiosAdapter

    await expect(request.get('/api/v1/books')).rejects.toMatchObject({
      appError: { kind: 'network' },
    })
    expect(getTokens().access).toBe('old-access')
  })

  it('classifies 5xx as server errors and keeps tokens', async () => {
    setTokens('old-access', 'old-refresh')
    request.defaults.adapter = (async (config: InternalAxiosRequestConfig) => {
      throw httpError(500, config)
    }) as AxiosAdapter

    await expect(request.get('/api/v1/books')).rejects.toMatchObject({
      appError: { kind: 'server' },
    })
    expect(getTokens().access).toBe('old-access')
  })

  it('does not refresh or invalidate a session on forbidden responses', async () => {
    setTokens('access', 'refresh')
    const invalid = vi.fn()
    window.addEventListener('auth:invalidated', invalid)
    request.defaults.adapter = async (config) => { throw httpError(403, config) }
    const post = vi.spyOn(axios, 'post')
    await expect(request.get('/private')).rejects.toBeDefined()
    expect(post).not.toHaveBeenCalled()
    expect(invalid).not.toHaveBeenCalled()
    window.removeEventListener('auth:invalidated', invalid)
  })

  it('keeps a session when token refresh encounters a network failure', async () => {
    setTokens('access', 'refresh')
    const invalid = vi.fn()
    window.addEventListener('auth:invalidated', invalid)
    request.defaults.adapter = async (config) => { throw httpError(401, config) }
    vi.spyOn(axios, 'post').mockRejectedValue(new AxiosError('offline', 'ERR_NETWORK'))
    await expect(request.get('/private')).rejects.toMatchObject({ appError: { kind: 'network' } })
    expect(getTokens().refresh).toBe('refresh')
    expect(invalid).not.toHaveBeenCalled()
    window.removeEventListener('auth:invalidated', invalid)
  })

  it('does not refresh when skipAuthRefresh is set', async () => {
    setTokens('old-access', 'old-refresh')
    request.defaults.adapter = (async (config: InternalAxiosRequestConfig) => {
      throw httpError(401, config)
    }) as AxiosAdapter
    const post = vi.spyOn(axios, 'post').mockResolvedValue(refreshOk() as never)

    await expect(
      request.get('/api/v1/auth/me', { skipAuthRefresh: true, skipAuth: true }),
    ).rejects.toMatchObject({ appError: { kind: 'unauthorized' } })
    expect(post).not.toHaveBeenCalled()
  })
})