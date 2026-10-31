import { AuthService } from '../api/AuthService';
import { ApiError } from '../api/HttpClient';
import { AuthStore } from '../store/AuthStore';
import { Constants } from '../common/Constants';
import { RouterHelper } from '../common/RouterHelper';
import { LoadingState } from '../components/LoadingState';
import promptAction from '@ohos.promptAction';

/**
 * 登录页
 */
@Entry
@Component
struct Login {
  @State username: string = '';
  @State password: string = '';
  @State loading: boolean = false;
  @State error: string = '';

  private async doLogin(): Promise<void> {
    if (this.username.length === 0 || this.password.length === 0) {
      this.error = '请输入用户名和密码';
      return;
    }
    this.loading = true;
    this.error = '';
    try {
      const tokenResp = await AuthService.login(this.username.trim(), this.password);
      await AuthStore.saveTokens(tokenResp.access_token, tokenResp.refresh_token);
      // 获取用户信息
      try {
        const user = await AuthService.me();
        await AuthStore.saveUser(user);
      } catch (e) {
        // 获取用户信息失败不阻塞登录
      }
      promptAction.showToast({ message: '登录成功' });
      RouterHelper.afterLogin();
    } catch (e) {
      if (e instanceof ApiError) {
        this.error = e.message;
      } else {
        this.error = '登录失败，请重试';
      }
    } finally {
      this.loading = false;
    }
  }

  build() {
    Column() {
      // 标题
      Text('小说阅读')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1B2432')
        .margin({ top: 80, bottom: 8 })

      Text('欢迎回来')
        .fontSize(14)
        .fontColor('#8B95A7')
        .margin({ bottom: 40 })

      if (this.loading) {
        LoadingState({ tip: '登录中...' })
      } else {
        // 用户名输入
        TextInput({ placeholder: '请输入用户名', text: this.username })
          .width('80%')
          .height(48)
          .fontSize(16)
          .borderRadius(8)
          .backgroundColor('#F5F7FB')
          .onChange((value: string) => {
            this.username = value;
          })

        // 密码输入
        TextInput({ placeholder: '请输入密码', text: this.password })
          .width('80%')
          .height(48)
          .fontSize(16)
          .borderRadius(8)
          .backgroundColor('#F5F7FB')
          .type(InputType.Password)
          .margin({ top: 16 })
          .onChange((value: string) => {
            this.password = value;
          })

        // 错误提示
        if (this.error.length > 0) {
          Text(this.error)
            .fontSize(13)
            .fontColor('#FF4D4F')
            .margin({ top: 12 })
        }

        // 登录按钮
        Button('登录')
          .width('80%')
          .height(48)
          .type(ButtonType.Capsule)
          .backgroundColor('#2F6BFF')
          .fontColor('#FFFFFF')
          .fontSize(16)
          .margin({ top: 24 })
          .onClick(() => this.doLogin())

        // 注册链接
        Text('还没有账号？立即注册')
          .fontSize(14)
          .fontColor('#2F6BFF')
          .margin({ top: 20 })
          .onClick(() => {
            RouterHelper.push(Constants.PAGE_REGISTER);
          })
      }

      // 返回首页
      Text('返回首页')
        .fontSize(14)
        .fontColor('#8B95A7')
        .margin({ top: 20 })
        .onClick(() => {
          RouterHelper.replace(Constants.PAGE_HOME);
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#FFFFFF')
  }
}