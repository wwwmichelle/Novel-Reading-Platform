import router from '@ohos.router';
import { Constants } from './Constants';

/**
 * 路由跳转封装
 * 统一管理页面跳转和参数传递
 */
export class RouterHelper {
  private static loginReturnUrl: string = '';
  private static loginReturnParams: Record<string, string> = {};

  static afterLogin(): void {
    const url = RouterHelper.loginReturnUrl || Constants.PAGE_HOME;
    const params = RouterHelper.loginReturnParams;
    RouterHelper.loginReturnUrl = '';
    RouterHelper.loginReturnParams = {};
    RouterHelper.replace(url, params);
  }

  /** 携带参数跳转页面 */
  static push(url: string, params?: Record<string, string>): void {
    if (url === Constants.PAGE_LOGIN) {
      const state = router.getState();
      if (state.path && state.name !== 'Login' && state.name !== 'Register') {
        RouterHelper.loginReturnUrl = state.path + state.name;
        RouterHelper.loginReturnParams = RouterHelper.getParams();
      }
    }
    if (params) {
      router.pushUrl({ url: url, params: params });
    } else {
      router.pushUrl({ url: url });
    }
  }

  /** 携带参数替换当前页面（不可返回） */
  static replace(url: string, params?: Record<string, string>): void {
    if (params) {
      router.replaceUrl({ url: url, params: params });
    } else {
      router.replaceUrl({ url: url });
    }
  }

  /** 返回上一页 */
  static back(): void {
    router.back();
  }

  /** 返回到指定页面 */
  static backTo(url: string): void {
    router.back({ url: url });
  }

  /** 获取路由参数，返回空对象表示无参数 */
  static getParams(): Record<string, string> {
    const params = router.getParams();
    if (params) {
      return params as Record<string, string>;
    }
    return {} as Record<string, string>;
  }

  /** 获取路由参数中的指定字段 */
  static getParam(key: string): string {
    const params = RouterHelper.getParams();
    return params[key] ?? '';
  }
}