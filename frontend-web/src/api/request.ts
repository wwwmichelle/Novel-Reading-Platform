import axios, { AxiosError, type InternalAxiosRequestConfig } from 'axios'

import { toAppError } from '@/utils/errors'
import { clearTokens, getTokens, setTokens } from '@/utils/session'

const baseURL = import.meta.env.VITE_API_BASE_URL ?? ''

export const AUTH_INVALID_EVENT = 'auth:invalidated'
export const AUTH_DEGRADED_EVENT = 'auth:degraded'

declare module 'axios' {
  export interface AxiosRequestConfig {
    skipAuth?: boolean
    skipAuthRefresh?: boolean
    timeoutMs?: number
    _retry?: boolean
  }
}

type RetriableConfig = InternalAxiosRequestConfig & {
  _retry?: boolean
  skipAuth?: boolean
  skipAuthRefresh?: boolean
  timeoutMs?: number
}

const request = axios.create({ baseURL, timeout: 15000 })

let refreshPromise: Promise<string | null> | null = null

function emit(eventName: string) {
  if (typeof window !== 'undefined') {
    window.dispatchEvent(new CustomEvent(eventName))
  }
}

async function refreshAccessToken(): Promise<string | null> {
  const { refresh } = getTokens()
  if (!refresh) return null
  try {
    const resp = await axios.post(
      `${baseURL}/api/v1/auth/refresh`,
      { refresh_token: refresh },
      { timeout: 10000 },
    )
    const { access_token, refresh_token } = resp.data
    setTokens(access_token, refresh_token)
    return access_token
  } catch (error) {
    const status = (error as AxiosError).response?.status
    if (status === 401 || status === 403) return null
    throw error
  }
}

function rejectWith(error: unknown) {
  const axiosError = error as AxiosError & { appError?: ReturnType<typeof toAppError> }
  if (!axiosError.appError) axiosError.appError = toAppError(error)
  return Promise.reject(axiosError)
}

request.interceptors.request.use((config: RetriableConfig) => {
  if (config.skipAuth) return config
  const { access } = getTokens()
  if (access && config.headers) {
    config.headers.Authorization = `Bearer ${access}`
  }
  if (config.timeoutMs) config.timeout = config.timeoutMs
  return config
})

request.interceptors.response.use(
  (response) => response,
  async (error: AxiosError) => {
    const original = error.config as RetriableConfig | undefined
    const status = error.response?.status

    if (!original || original.skipAuthRefresh) return rejectWith(error)
    if (status !== 401) {
      const kind = toAppError(error).kind
      if (kind === 'network' || kind === 'server') emit(AUTH_DEGRADED_EVENT)
      return rejectWith(error)
    }

    if (original._retry) {
      emit(AUTH_INVALID_EVENT)
      return rejectWith(error)
    }
    original._retry = true

    if (!refreshPromise) {
      refreshPromise = refreshAccessToken().finally(() => {
        refreshPromise = null
      })
    }
    let token: string | null
    try {
      token = await refreshPromise
    } catch (refreshError) {
      emit(AUTH_DEGRADED_EVENT)
      return rejectWith(refreshError)
    }
    if (!token) {
      emit(AUTH_INVALID_EVENT)
      return rejectWith(error)
    }
    if (original.headers) {
      original.headers.Authorization = `Bearer ${token}`
    }
    return request(original)
  },
)

export { request, getTokens, setTokens, clearTokens }
