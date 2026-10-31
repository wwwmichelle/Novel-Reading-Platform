import preferences from '@ohos.data.preferences';
import { common } from '@ohos.app.ability';
import { HttpClient } from '../api/HttpClient';
import { Constants } from '../common/Constants';
import { UserResponse } from '../model/ApiModels';

/**
 * 认证状态管理
 * 使用 @ohos.data.preferences 持久化令牌和用户信息
 * 与 HttpClient 双向同步令牌缓存
 */
export class AuthStore {
  private static context: common.UIAbilityContext | null = null;

  static accessToken: string = '';
  static refreshToken: string = '';
  static userId: string = '';
  static userName: string = '';
  static userRole: string = '';

  /** 是否已登录 */
  static isLoggedIn(): boolean {
    return AuthStore.accessToken.length > 0;
  }

  /**
   * 初始化：从 preferences 加载令牌和用户信息，同步到 HttpClient，注册回调
   * 在 EntryAbility.onCreate 中调用
   */
  static async init(context: common.UIAbilityContext): Promise<void> {
    AuthStore.context = context;
    try {
      const pref = await preferences.getPreferences(context, Constants.PREF_NAME);
      AuthStore.accessToken = await pref.get(Constants.PREF_KEY_ACCESS_TOKEN, '');
      AuthStore.refreshToken = await pref.get(Constants.PREF_KEY_REFRESH_TOKEN, '');
      AuthStore.userId = await pref.get(Constants.PREF_KEY_USER_ID, '');
      AuthStore.userName = await pref.get(Constants.PREF_KEY_USER_NAME, '');
      AuthStore.userRole = await pref.get(Constants.PREF_KEY_USER_ROLE, '');

      // 同步到 HttpClient
      HttpClient.accessToken = AuthStore.accessToken;
      HttpClient.refreshToken = AuthStore.refreshToken;

      // 注册令牌刷新回调
      HttpClient.onTokenRefreshed = (access: string, refresh: string): void => {
        AuthStore.accessToken = access;
        AuthStore.refreshToken = refresh;
        AuthStore.persistTokens();
      };
      // 注册令牌失效回调
      HttpClient.onTokenInvalid = (): void => {
        AuthStore.clearAll();
      };

      console.info('AuthStore initialized, loggedIn=' + AuthStore.isLoggedIn());
    } catch (e) {
      console.error('AuthStore init failed: ' + JSON.stringify(e));
    }
  }

  /** 保存令牌（登录成功后调用） */
  static async saveTokens(access: string, refresh: string): Promise<void> {
    AuthStore.accessToken = access;
    AuthStore.refreshToken = refresh;
    HttpClient.accessToken = access;
    HttpClient.refreshToken = refresh;
    await AuthStore.persistTokens();
  }

  /** 保存用户信息 */
  static async saveUser(user: UserResponse): Promise<void> {
    AuthStore.userId = user.id;
    AuthStore.userName = user.username;
    AuthStore.userRole = user.role;
    await AuthStore.persistUser();
  }

  /** 退出登录：清除所有认证信息 */
  static async logout(): Promise<void> {
    AuthStore.accessToken = '';
    AuthStore.refreshToken = '';
    AuthStore.userId = '';
    AuthStore.userName = '';
    AuthStore.userRole = '';
    HttpClient.accessToken = '';
    HttpClient.refreshToken = '';
    await AuthStore.clearPersist();
  }

  /** 持久化令牌 */
  private static async persistTokens(): Promise<void> {
    if (AuthStore.context === null) {
      return;
    }
    try {
      const pref = await preferences.getPreferences(AuthStore.context, Constants.PREF_NAME);
      await pref.put(Constants.PREF_KEY_ACCESS_TOKEN, AuthStore.accessToken);
      await pref.put(Constants.PREF_KEY_REFRESH_TOKEN, AuthStore.refreshToken);
      await pref.flush();
    } catch (e) {
      console.error('persistTokens failed: ' + JSON.stringify(e));
    }
  }

  /** 持久化用户信息 */
  private static async persistUser(): Promise<void> {
    if (AuthStore.context === null) {
      return;
    }
    try {
      const pref = await preferences.getPreferences(AuthStore.context, Constants.PREF_NAME);
      await pref.put(Constants.PREF_KEY_USER_ID, AuthStore.userId);
      await pref.put(Constants.PREF_KEY_USER_NAME, AuthStore.userName);
      await pref.put(Constants.PREF_KEY_USER_ROLE, AuthStore.userRole);
      await pref.flush();
    } catch (e) {
      console.error('persistUser failed: ' + JSON.stringify(e));
    }
  }

  /** 清除持久化数据 */
  private static async clearPersist(): Promise<void> {
    if (AuthStore.context === null) {
      return;
    }
    try {
      const pref = await preferences.getPreferences(AuthStore.context, Constants.PREF_NAME);
      await pref.delete(Constants.PREF_KEY_ACCESS_TOKEN);
      await pref.delete(Constants.PREF_KEY_REFRESH_TOKEN);
      await pref.delete(Constants.PREF_KEY_USER_ID);
      await pref.delete(Constants.PREF_KEY_USER_NAME);
      await pref.delete(Constants.PREF_KEY_USER_ROLE);
      await pref.flush();
    } catch (e) {
      console.error('clearPersist failed: ' + JSON.stringify(e));
    }
  }

  /** 清除所有认证信息（令牌失效时调用） */
  private static async clearAll(): Promise<void> {
    AuthStore.accessToken = '';
    AuthStore.refreshToken = '';
    AuthStore.userId = '';
    AuthStore.userName = '';
    AuthStore.userRole = '';
    HttpClient.accessToken = '';
    HttpClient.refreshToken = '';
    await AuthStore.clearPersist();
  }
}