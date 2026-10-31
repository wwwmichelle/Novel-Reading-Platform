import { common } from '@ohos.app.ability';
import util from '@ohos.util';

/** 运行时配置接口 */
interface AppConfig {
  api_base_url: string;
  timeout_ms: number;
}

/**
 * 全局常量定义
 * API_BASE_URL 通过运行时配置（rawfile/config.json）加载，不硬编码
 */
export class Constants {
  /** API 基础地址（从配置文件读取，默认值仅作 fallback） */
  static API_BASE_URL: string = 'http://localhost:8000';
  /** 请求超时时间（毫秒） */
  static TIMEOUT_MS: number = 15000;

  /** Preferences 存储名称 */
  static PREF_NAME: string = 'novel_reader_pref';
  /** 令牌存储键 */
  static PREF_KEY_ACCESS_TOKEN: string = 'access_token';
  static PREF_KEY_REFRESH_TOKEN: string = 'refresh_token';
  static PREF_KEY_USER_ID: string = 'user_id';
  static PREF_KEY_USER_NAME: string = 'user_name';
  static PREF_KEY_USER_ROLE: string = 'user_role';
  /** 阅读设置存储键 */
  static PREF_KEY_FONT_SIZE: string = 'font_size';
  static PREF_KEY_THEME: string = 'theme';

  /** 字号范围 */
  static FONT_SIZE_MIN: number = 12;
  static FONT_SIZE_MAX: number = 32;
  static FONT_SIZE_DEFAULT: number = 18;

  /** 分页默认值 */
  static DEFAULT_PAGE_SIZE: number = 20;

  /** 路由页面路径 */
  static readonly PAGE_LOGIN: string = 'pages/Login';
  static readonly PAGE_REGISTER: string = 'pages/Register';
  static readonly PAGE_HOME: string = 'pages/Home';
  static readonly PAGE_CATEGORY_LIST: string = 'pages/CategoryList';
  static readonly PAGE_CATEGORY_BOOKS: string = 'pages/CategoryBooks';
  static readonly PAGE_SEARCH: string = 'pages/Search';
  static readonly PAGE_BOOK_DETAIL: string = 'pages/BookDetail';
  static readonly PAGE_CHAPTER_LIST: string = 'pages/ChapterList';
  static readonly PAGE_READING: string = 'pages/Reading';
  static readonly PAGE_BOOKSHELF: string = 'pages/Bookshelf';
  static readonly PAGE_PROFILE: string = 'pages/Profile';

  /**
   * 从 rawfile/config.json 加载运行时配置
   * 在 EntryAbility.onCreate 中调用
   */
  static async initConfig(context: common.UIAbilityContext): Promise<void> {
    try {
      const content: Uint8Array = await context.resourceManager.getRawFileContent('config.json');
      const textDecoder = util.TextDecoder.create('utf-8');
      const text: string = textDecoder.decodeWithStream(content);
      const config = JSON.parse(text) as AppConfig;
      if (config.api_base_url && config.api_base_url.length > 0) {
        Constants.API_BASE_URL = config.api_base_url;
      }
      if (config.timeout_ms && config.timeout_ms > 0) {
        Constants.TIMEOUT_MS = config.timeout_ms;
      }
      console.info('Config loaded: API_BASE_URL=' + Constants.API_BASE_URL);
    } catch (e) {
      console.error('Failed to load config, using defaults: ' + JSON.stringify(e));
    }
  }

  /** 拼接完整 API 地址 */
  static apiUrl(path: string): string {
    return Constants.API_BASE_URL + path;
  }
}