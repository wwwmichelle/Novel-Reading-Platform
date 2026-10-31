import { AuthService } from '../api/AuthService';
import { ApiError } from '../api/HttpClient';
import { Constants } from '../common/Constants';
import { RouterHelper } from '../common/RouterHelper';
import { LoadingState } from '../components/LoadingState';
import promptAction from '@ohos.promptAction';

/**
 * 注册页
 */
@Entry
@Component
struct Register {
  @State username: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State loading: boolean = false;
  @State error: string = '';

  private async doRegister(): Promise<void> {
    if (this.username.length < 3) {
      this.error = '用户名至少3个字符';
      return;
    }
    if (this.password.length < 6) {
      this.error = '密码至少6个字符';
      return;
    }
    if (this.password !== this.confirmPassword) {
      this.error = '两次输入的密码不一致';
      return;
    }
    this.loading = true;
    this.error = '';
    try {
      await AuthService.register(this.username, this.password);
      promptAction.showToast({ message: '注册成功，请登录' });
      RouterHelper.replace(Constants.PAGE_LOGIN);
    } catch (e) {
      if (e instanceof ApiError) {
        this.error = e.message;
      } else {
        this.error = '注册失败，请重试';
      }
    } finally {
      this.loading = false;
    }
  }

  build() {
    Column() {
      Text('注册账号')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1B2432')
        .margin({ top: 80, bottom: 40 })

      if (this.loading) {
        LoadingState({ tip: '注册中...' })
      } else {
        TextInput({ placeholder: '用户名（至少3个字符）', text: this.username })
          .width('80%')
          .height(48)
          .fontSize(16)
          .borderRadius(8)
          .backgroundColor('#F5F7FB')
          .onChange((value: string) => {
            this.username = value;
          })

        TextInput({ placeholder: '密码（至少6个字符）', text: this.password })
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

        TextInput({ placeholder: '确认密码', text: this.confirmPassword })
          .width('80%')
          .height(48)
          .fontSize(16)
          .borderRadius(8)
          .backgroundColor('#F5F7FB')
          .type(InputType.Password)
          .margin({ top: 16 })
          .onChange((value: string) => {
            this.confirmPassword = value;
          })

        if (this.error.length > 0) {
          Text(this.error)
            .fontSize(13)
            .fontColor('#FF4D4F')
            .margin({ top: 12 })
        }

        Button('注册')
          .width('80%')
          .height(48)
          .type(ButtonType.Capsule)
          .backgroundColor('#2F6BFF')
          .fontColor('#FFFFFF')
          .fontSize(16)
          .margin({ top: 24 })
          .onClick(() => this.doRegister())

        Text('已有账号？返回登录')
          .fontSize(14)
          .fontColor('#2F6BFF')
          .margin({ top: 20 })
          .onClick(() => {
            RouterHelper.replace(Constants.PAGE_LOGIN);
          })
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#FFFFFF')
  }
}