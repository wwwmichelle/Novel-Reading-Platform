import type { TokenResponse, UserResponse } from '@/types/api'
import { request } from './request'

export const authApi = {
  register: (username: string, password: string) =>
    request.post<UserResponse>('/api/v1/auth/register', { username, password }, { skipAuth: true, skipAuthRefresh: true }),

  login: (username: string, password: string) =>
    request.post<TokenResponse>('/api/v1/auth/login', { username, password }, { skipAuth: true, skipAuthRefresh: true }),

  refresh: (refreshToken: string) =>
    request.post<TokenResponse>(
      '/api/v1/auth/refresh',
      { refresh_token: refreshToken },
      { skipAuth: true, skipAuthRefresh: true, timeoutMs: 10000 },
    ),

  logout: async (): Promise<void> => {
    try {
      await request.post('/api/v1/auth/logout', null, { skipAuthRefresh: true })
    } catch {
      // 登出失败不阻塞本地清理
    }
  },

  me: () => request.get<UserResponse>('/api/v1/auth/me'),
}
