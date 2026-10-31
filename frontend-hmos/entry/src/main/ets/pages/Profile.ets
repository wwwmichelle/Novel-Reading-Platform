import { AuthService } from '../api/AuthService';

import { AuthStore } from '../store/AuthStore';
import { ReadingStore } from '../store/ReadingStore';
import { Constants } from '../common/Constants';
import { RouterHelper } from '../common/RouterHelper';
import promptAction from '@ohos.promptAction';

/**
 * 个人中心页
 */
@Entry
@Component
struct Profile {
  @State isLoggedIn: boolean = false;
  @State userName: string = '';
  @State userRole: string = '';
  @State fontSize: number = 18;
  @State isDark: boolean = false;

  aboutToAppear(): void {
    this.refreshUser();
  }

  onPageShow(): void {
    this.refreshUser();
  }

  private refreshUser(): void {
    this.isLoggedIn = AuthStore.isLoggedIn();
    this.userName = AuthStore.userName;
    this.userRole = AuthStore.userRole;
    this.fontSize = ReadingStore.fontSize;
    this.isDark = ReadingStore.isDark();
  }

  private async doLogout(): Promise<void> {
    try {
      const result = await promptAction.showDialog({
        title: '确认退出',
        message: '确定要退出登录吗？',
        buttons: [
          { text: '取消', color: '#59647A' },
          { text: '退出', color: '#FF4D4F' }
        ]
      });
      if (result.index === 1) {
        try {
          await AuthService.logout();
        } catch (e) {
          // 忽略退出失败
        }
        await AuthStore.logout();
        this.refreshUser();
        promptAction.showToast({ message: '已退出登录' });
      }
    } catch (e) {
      // 忽略
    }
  }

  private async decreaseFont(): Promise<void> {
    await ReadingStore.decreaseFontSize();
    this.fontSize = ReadingStore.fontSize;
  }

  private async increaseFont(): Promise<void> {
    await ReadingStore.increaseFontSize();
    this.fontSize = ReadingStore.fontSize;
  }

  private async toggleTheme(): Promise<void> {
    await ReadingStore.toggleTheme();
    this.isDark = ReadingStore.isDark();
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Text('←')
          .fontSize(22)
          .fontColor('#1B2432')
          .onClick(() => RouterHelper.back())
        Text('个人中心')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1B2432')
          .margin({ left: 12 })
        Blank()
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#FFFFFF')

      Divider().color('#E2E8F2').strokeWidth(1)

      Scroll() {
        Column() {
          // 用户信息卡片
          Row() {
            Column() {
              Text(this.isLoggedIn && this.userName.length > 0 ? this.userName.charAt(0).toUpperCase() : '?')
                .fontSize(32)
                .fontColor('#FFFFFF')
            }
            .width(64)
            .height(64)
            .borderRadius(32)
            .backgroundColor('#2F6BFF')
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)

            Column() {
              Text(this.isLoggedIn ? this.userName : '未登录')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#1B2432')

              if (this.isLoggedIn) {
                Text('角色：' + (this.userRole === 'admin' ? '管理员' : '普通用户'))
                  .fontSize(13)
                  .fontColor('#8B95A7')
                  .margin({ top: 4 })
              } else {
                Text('登录后享受更多功能')
                  .fontSize(13)
                  .fontColor('#8B95A7')
                  .margin({ top: 4 })
              }
            }
            .margin({ left: 16 })
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            if (!this.isLoggedIn) {
              Button('登录')
                .width(72)
                .height(36)
                .type(ButtonType.Capsule)
                .backgroundColor('#2F6BFF')
                .fontColor('#FFFFFF')
                .fontSize(14)
                .onClick(() => {
                  RouterHelper.push(Constants.PAGE_LOGIN);
                })
            }
          }
          .width('100%')
          .padding(16)
          .alignItems(VerticalAlign.Center)

          Divider().color('#F0F0F0').strokeWidth(1)

          // 功能菜单
          Text('功能')
            .fontSize(14)
            .fontColor('#8B95A7')
            .margin({ top: 16, left: 16 })
            .alignSelf(ItemAlign.Start)

          // 我的书架
          Row() {
            Text('📚')
              .fontSize(20)
              .margin({ right: 12 })
            Text('我的书架')
              .fontSize(16)
              .fontColor('#1B2432')
              .layoutWeight(1)
            Text('>')
              .fontSize(16)
              .fontColor('#CCCCCC')
          }
          .width('100%')
          .height(52)
          .padding({ left: 16, right: 16 })
          .alignItems(VerticalAlign.Center)
          .onClick(() => {
            RouterHelper.push(Constants.PAGE_BOOKSHELF);
          })
          Divider().color('#F5F7FB').strokeWidth(1)

          // 搜索
          Row() {
            Text('🔍')
              .fontSize(20)
              .margin({ right: 12 })
            Text('搜索图书')
              .fontSize(16)
              .fontColor('#1B2432')
              .layoutWeight(1)
            Text('>')
              .fontSize(16)
              .fontColor('#CCCCCC')
          }
          .width('100%')
          .height(52)
          .padding({ left: 16, right: 16 })
          .alignItems(VerticalAlign.Center)
          .onClick(() => {
            RouterHelper.push(Constants.PAGE_SEARCH);
          })
          Divider().color('#F5F7FB').strokeWidth(1)

          // 分类
          Row() {
            Text('📋')
              .fontSize(20)
              .margin({ right: 12 })
            Text('浏览分类')
              .fontSize(16)
              .fontColor('#1B2432')
              .layoutWeight(1)
            Text('>')
              .fontSize(16)
              .fontColor('#CCCCCC')
          }
          .width('100%')
          .height(52)
          .padding({ left: 16, right: 16 })
          .alignItems(VerticalAlign.Center)
          .onClick(() => {
            RouterHelper.push(Constants.PAGE_CATEGORY_LIST);
          })
          Divider().color('#F5F7FB').strokeWidth(1)

          // 阅读设置
          Text('阅读设置')
            .fontSize(14)
            .fontColor('#8B95A7')
            .margin({ top: 24, left: 16 })
            .alignSelf(ItemAlign.Start)

          // 字号设置
          Row() {
            Text('字号')
              .fontSize(16)
              .fontColor('#1B2432')
              .layoutWeight(1)
            Text('A-')
              .fontSize(18)
              .fontColor('#2F6BFF')
              .padding({ left: 12, right: 12 })
              .onClick(() => this.decreaseFont())
            Text(this.fontSize.toString() + ' px')
              .fontSize(14)
              .fontColor('#59647A')
              .margin({ left: 8, right: 8 })
            Text('A+')
              .fontSize(18)
              .fontColor('#2F6BFF')
              .padding({ left: 12, right: 12 })
              .onClick(() => this.increaseFont())
          }
          .width('100%')
          .height(52)
          .padding({ left: 16, right: 16 })
          .alignItems(VerticalAlign.Center)
          Divider().color('#F5F7FB').strokeWidth(1)

          // 主题设置
          Row() {
            Text('阅读主题')
              .fontSize(16)
              .fontColor('#1B2432')
              .layoutWeight(1)
            Text(this.isDark ? '🌙 夜间模式' : '☀️ 日间模式')
              .fontSize(14)
              .fontColor('#59647A')
          }
          .width('100%')
          .height(52)
          .padding({ left: 16, right: 16 })
          .alignItems(VerticalAlign.Center)
          .onClick(() => this.toggleTheme())
          Divider().color('#F5F7FB').strokeWidth(1)

          // 退出登录
          if (this.isLoggedIn) {
            Button('退出登录')
              .width('90%')
              .height(44)
              .type(ButtonType.Normal)
              .borderRadius(8)
              .backgroundColor('#FFFFFF')
              .fontColor('#FF4D4F')
              .fontSize(16)
              .margin({ top: 40 })
              .border({ width: 1, color: '#FF4D4F', radius: 8 })
              .onClick(() => this.doLogout())
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}