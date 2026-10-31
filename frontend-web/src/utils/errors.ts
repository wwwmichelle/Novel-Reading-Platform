import type { AxiosError } from 'axios'

export type AppErrorKind = 'unauthorized' | 'network' | 'server' | 'client'

export interface AppError {
  kind: AppErrorKind
  status?: number
  code?: string
  message: string
}

const FALLBACK_MESSAGES: Record<AppErrorKind, string> = {
  unauthorized: '登录已失效，请重新登录',
  network: '网络连接异常，请检查网络后重试',
  server: '服务暂时不可用，请稍后重试',
  client: '请求未能完成，请稍后重试',
}

export function toAppError(error: unknown): AppError {
  const axiosError = error as AxiosError<{ message?: string }> | undefined
  const response = axiosError?.response
  const status = response?.status
  const serverMessage = response?.data?.message

  let kind: AppErrorKind = 'client'
  if (status === 401) kind = 'unauthorized'
  else if (!response || axiosError?.code === 'ECONNABORTED' || axiosError?.code === 'ERR_NETWORK') kind = 'network'
  else if (status && status >= 500) kind = 'server'

  return {
    kind,
    status,
    code: axiosError?.code,
    message: typeof serverMessage === 'string' && serverMessage ? serverMessage : FALLBACK_MESSAGES[kind],
  }
}

export function isCanceled(error: unknown): boolean {
  const axiosError = error as AxiosError | undefined
  return axiosError?.code === 'ERR_CANCELED'
}

export function isUnauthorized(error: unknown): boolean {
  return toAppError(error).kind === 'unauthorized'
}