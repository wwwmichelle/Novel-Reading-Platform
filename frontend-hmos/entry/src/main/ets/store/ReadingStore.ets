import preferences from '@ohos.data.preferences';
import { common } from '@ohos.app.ability';
import { Constants } from '../common/Constants';

/**
 * 阅读设置状态管理
 * 持久化字号和主题（日间/夜间）
 */
export class ReadingStore {
  private static context: common.UIAbilityContext | null = null;

  /** 字号 */
  static fontSize: number = Constants.FONT_SIZE_DEFAULT;
  /** 主题：'light' 或 'dark' */
  static theme: string = 'light';

  /** 是否夜间模式 */
  static isDark(): boolean {
    return ReadingStore.theme === 'dark';
  }

  /** 初始化：从 preferences 加载阅读设置 */
  static async init(context: common.UIAbilityContext): Promise<void> {
    ReadingStore.context = context;
    try {
      const pref = await preferences.getPreferences(context, Constants.PREF_NAME);
      ReadingStore.fontSize = await pref.get(Constants.PREF_KEY_FONT_SIZE, Constants.FONT_SIZE_DEFAULT);
      ReadingStore.theme = await pref.get(Constants.PREF_KEY_THEME, 'light');
    } catch (e) {
      console.error('ReadingStore init failed: ' + JSON.stringify(e));
    }
  }

  /** 设置字号（自动限制范围） */
  static async setFontSize(size: number): Promise<void> {
    const clamped: number = Math.max(Constants.FONT_SIZE_MIN, Math.min(Constants.FONT_SIZE_MAX, size));
    ReadingStore.fontSize = clamped;
    await ReadingStore.persist();
  }

  /** 增大字号 */
  static async increaseFontSize(): Promise<void> {
    await ReadingStore.setFontSize(ReadingStore.fontSize + 1);
  }

  /** 减小字号 */
  static async decreaseFontSize(): Promise<void> {
    await ReadingStore.setFontSize(ReadingStore.fontSize - 1);
  }

  /** 切换日间/夜间主题 */
  static async toggleTheme(): Promise<void> {
    ReadingStore.theme = ReadingStore.theme === 'light' ? 'dark' : 'light';
    await ReadingStore.persist();
  }

  /** 持久化阅读设置 */
  private static async persist(): Promise<void> {
    if (ReadingStore.context === null) {
      return;
    }
    try {
      const pref = await preferences.getPreferences(ReadingStore.context, Constants.PREF_NAME);
      await pref.put(Constants.PREF_KEY_FONT_SIZE, ReadingStore.fontSize);
      await pref.put(Constants.PREF_KEY_THEME, ReadingStore.theme);
      await pref.flush();
    } catch (e) {
      console.error('ReadingStore persist failed: ' + JSON.stringify(e));
    }
  }
}