import UIAbility from '@ohos.app.ability.UIAbility';
import type Want from '@ohos.app.ability.Want';
import type AbilityConstant from '@ohos.app.ability.AbilityConstant';
import window from '@ohos.window';
import { Constants } from '../common/Constants';
import { AuthStore } from '../store/AuthStore';
import { ReadingStore } from '../store/ReadingStore';

/**
 * 应用入口 Ability
 * 负责初始化运行时配置、认证状态、阅读设置
 */
export default class EntryAbility extends UIAbility {
  private initialization: Promise<void> = Promise.resolve();
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    // 1. 加载运行时配置（API_BASE_URL 等）
    this.initialization = Constants.initConfig(this.context).then((): Promise<void> => {
      // 2. 初始化认证状态（从 preferences 恢复令牌）
      return AuthStore.init(this.context);
    }).then((): Promise<void> => {
      // 3. 初始化阅读设置（字号/主题）
      return ReadingStore.init(this.context);
    }).then((): void => {
      console.info('EntryAbility onCreate completed');
    }).catch((e): void => {
      console.error('EntryAbility init failed: ' + JSON.stringify(e));
    });
  }

  onWindowStageCreate(windowStage: window.WindowStage) {
    // 加载首页（无论是否登录都可浏览）
    this.initialization.then(() => {
    windowStage.loadContent('pages/Home', (err) => {
      if (err.code) {
        console.error('Failed to load content. Cause: ' + JSON.stringify(err));
        return;
      }
      console.info('Succeeded in loading content.');
    });
    });
  }

  onDestroy() {
    console.info('EntryAbility onDestroy');
  }
}