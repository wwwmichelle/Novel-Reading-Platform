import http from '@ohos.net.http';
import { Constants } from '../common/Constants';
import { ErrorResponse, TokenResponse } from '../model/ApiModels';

/** API 统一错误 */
export class ApiError {
  code: number;
  message: string;
  errorBody: ErrorResponse | null;

  constructor(code: number, message: string, errorBody: ErrorResponse | null) {
    this.code = code;
    this.message = message;
    this.errorBody = errorBody;
  }
}

/** 请求选项 */
interface RequestOptions {
  method: http.RequestMethod;
  path: string;
  query: Record<string, string> | null;
  body: string | null;
  needAuth: boolean;
  retried: boolean;
}

/**
 * HTTP 客户端封装
 * - 基于 @ohos.net.http
 * - 自动令牌注入（Bearer）
 * - 401 拦截刷新
 * - 统一错误处理
 */
export class HttpClient {
  /** 令牌缓存（由 AuthStore 同步） */
  static accessToken: string = '';
  static refreshToken: string = '';

  /** 令牌刷新成功回调（通知 AuthStore 持久化） */
  static onTokenRefreshed: ((access: string, refresh: string) => void) | null = null;
  /** 令牌失效回调（通知 AuthStore 清除并跳转登录） */
  static onTokenInvalid: (() => void) | null = null;

  private static refreshPromise: Promise<boolean> | null = null;

  /** GET 请求 */
  static get<T>(path: string, needAuth: boolean = false, query: Record<string, string> | null = null): Promise<T> {
    return HttpClient.request<T>({
      method: http.RequestMethod.GET,
      path: path,
      query: query,
      body: null,
      needAuth: needAuth,
      retried: false
    });
  }

  /** POST 请求 */
  static post<T>(path: string, body: string | null = null, needAuth: boolean = false): Promise<T> {
    return HttpClient.request<T>({
      method: http.RequestMethod.POST,
      path: path,
      query: null,
      body: body,
      needAuth: needAuth,
      retried: false
    });
  }

  /** PUT 请求 */
  static put<T>(path: string, body: string | null = null, needAuth: boolean = false): Promise<T> {
    return HttpClient.request<T>({
      method: http.RequestMethod.PUT,
      path: path,
      query: null,
      body: body,
      needAuth: needAuth,
      retried: false
    });
  }

  /** DELETE 请求 */
  static delete<T>(path: string, needAuth: boolean = false): Promise<T> {
    return HttpClient.request<T>({
      method: http.RequestMethod.DELETE,
      path: path,
      query: null,
      body: null,
      needAuth: needAuth,
      retried: false
    });
  }

  /** 核心请求方法 */
  private static async request<T>(options: RequestOptions): Promise<T> {
    const url: string = HttpClient.buildUrl(options.path, options.query);
    const header: Record<string, string> = {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };
    if (options.needAuth && HttpClient.accessToken.length > 0) {
      header['Authorization'] = 'Bearer ' + HttpClient.accessToken;
    }

    let result: http.HttpResponse;
    try {
      result = await HttpClient.doRequest(url, options, header);
    } catch (e) {
      throw new ApiError(0, '网络请求失败，请检查网络连接', null);
    }

    // 401 拦截：尝试刷新令牌后重试一次
    if (result.responseCode === 401 && options.needAuth && !options.retried) {
      const refreshed: boolean = await HttpClient.tryRefreshToken();
      if (refreshed && HttpClient.accessToken.length > 0) {
        header['Authorization'] = 'Bearer ' + HttpClient.accessToken;
        const retryOptions: RequestOptions = {
          method: options.method,
          path: options.path,
          query: options.query,
          body: options.body,
          needAuth: options.needAuth,
          retried: true
        };
        let retryResult: http.HttpResponse;
        try {
          retryResult = await HttpClient.doRequest(url, retryOptions, header);
        } catch (e) {
          throw new ApiError(0, '网络请求失败，请检查网络连接', null);
        }
        return HttpClient.parseResponse<T>(retryResult);
      } else {
        if (HttpClient.onTokenInvalid) {
          HttpClient.onTokenInvalid();
        }
        throw new ApiError(401, '登录已失效，请重新登录', null);
      }
    }

    return HttpClient.parseResponse<T>(result);
  }

  /** 执行底层 HTTP 请求 */
  private static async doRequest(url: string, options: RequestOptions, header: Record<string, string>): Promise<http.HttpResponse> {
    const httpRequest = http.createHttp();
    try {
      const requestOptions: http.HttpRequestOptions = {
        method: options.method,
        header: header,
        expectDataType: http.HttpDataType.STRING,
        connectTimeout: Constants.TIMEOUT_MS,
        readTimeout: Constants.TIMEOUT_MS
      };
      if (options.body !== null) {
        requestOptions.extraData = options.body;
      }
      const result = await httpRequest.request(url, requestOptions);
      return result;
    } finally {
      httpRequest.destroy();
    }
  }

  /** 尝试用 refresh_token 刷新令牌 */
  private static async tryRefreshToken(): Promise<boolean> {
    if (HttpClient.refreshPromise !== null) {
      return HttpClient.refreshPromise;
    }
    HttpClient.refreshPromise = HttpClient.performRefresh().finally(() => {
      HttpClient.refreshPromise = null;
    });
    return HttpClient.refreshPromise;
  }

  private static async performRefresh(): Promise<boolean> {
    if (HttpClient.refreshToken.length === 0) {
      return false;
    }
    try {
      const url: string = Constants.apiUrl('/api/v1/auth/refresh');
      const httpRequest = http.createHttp();
      try {
        const result = await httpRequest.request(url, {
          method: http.RequestMethod.POST,
          header: { 'Content-Type': 'application/json' },
          extraData: JSON.stringify({ refresh_token: HttpClient.refreshToken }),
          expectDataType: http.HttpDataType.STRING,
          connectTimeout: Constants.TIMEOUT_MS,
          readTimeout: Constants.TIMEOUT_MS
        });
        if (result.responseCode === 200) {
          const text = result.result as string;
          const tokenResp = JSON.parse(text) as TokenResponse;
          HttpClient.accessToken = tokenResp.access_token;
          HttpClient.refreshToken = tokenResp.refresh_token;
          if (HttpClient.onTokenRefreshed) {
            HttpClient.onTokenRefreshed(tokenResp.access_token, tokenResp.refresh_token);
          }
          return true;
        }
        if (result.responseCode === 401 || result.responseCode === 403) {
          return false;
        }
        throw new ApiError(result.responseCode, '服务暂时不可用，请稍后重试', null);
      } finally {
        httpRequest.destroy();
      }
    } catch (e) {
      throw new ApiError(0, '登录续期暂时失败，请检查网络后重试', null);
    }
  }

  /** 拼接 URL 和 query 参数 */
  private static buildUrl(path: string, query: Record<string, string> | null): string {
    let url: string = Constants.apiUrl(path);
    if (query !== null) {
      const keys = Object.keys(query);
      if (keys.length > 0) {
        const parts: string[] = [];
        for (let i = 0; i < keys.length; i++) {
          parts.push(keys[i] + '=' + encodeURIComponent(query[keys[i]]));
        }
        url += '?' + parts.join('&');
      }
    }
    return url;
  }

  /** 解析响应，非 2xx 抛出 ApiError */
  private static parseResponse<T>(result: http.HttpResponse): T {
    const code: number = result.responseCode;
    if (code >= 200 && code < 300) {
      const text = result.result as string;
      if (text && text.length > 0) {
        return JSON.parse(text) as T;
      }
      return {} as T;
    }
    // 解析错误响应体
    let errorBody: ErrorResponse | null = null;
    try {
      const text = result.result as string;
      if (text && text.length > 0) {
        errorBody = JSON.parse(text) as ErrorResponse;
      }
    } catch (e) {
      // 忽略解析错误
    }
    const message: string = errorBody !== null && errorBody.message.length > 0
      ? errorBody.message
      : '请求失败（HTTP ' + code + '）';
    throw new ApiError(code, message, errorBody);
  }
}