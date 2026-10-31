import { HttpClient } from './HttpClient';
import {
  UserResponse,
  TokenResponse,
  RegisterRequest,
  LoginRequest,
  RefreshRequest
} from '../model/ApiModels';

/**
 * 认证相关 API
 */
export class AuthService {
  /** 注册 */
  static register(username: string, password: string): Promise<UserResponse> {
    const body: RegisterRequest = { username: username, password: password };
    return HttpClient.post<UserResponse>('/api/v1/auth/register', JSON.stringify(body), false);
  }

  /** 登录 */
  static login(username: string, password: string): Promise<TokenResponse> {
    const body: LoginRequest = { username: username, password: password };
    return HttpClient.post<TokenResponse>('/api/v1/auth/login', JSON.stringify(body), false);
  }

  /** 刷新令牌 */
  static refresh(refreshToken: string): Promise<TokenResponse> {
    const body: RefreshRequest = { refresh_token: refreshToken };
    return HttpClient.post<TokenResponse>('/api/v1/auth/refresh', JSON.stringify(body), false);
  }

  /** 获取当前用户信息（需登录） */
  static me(): Promise<UserResponse> {
    return HttpClient.get<UserResponse>('/api/v1/auth/me', true);
  }

  /** 退出登录（需登录） */
  static logout(): Promise<void> {
    return HttpClient.post<void>('/api/v1/auth/logout', null, true);
  }
}