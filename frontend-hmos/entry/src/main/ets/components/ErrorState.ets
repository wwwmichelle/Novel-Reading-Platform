/**
 * 错误状态组件（含重试按钮）
 */
@Component
export struct ErrorState {
  @Prop tip: string = '加载失败';
  retry: () => void = (): void => {};

  build() {
    Column() {
      Text('⚠️')
        .fontSize(48)
      Text(this.tip)
        .fontSize(14)
        .fontColor('#FF4D4F')
        .margin({ top: 12 })
        .textAlign(TextAlign.Center)
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Button('重试')
        .type(ButtonType.Normal)
        .borderRadius(6)
        .backgroundColor('#2F6BFF')
        .fontColor('#FFFFFF')
        .height(36)
        .padding({ left: 24, right: 24 })
        .margin({ top: 16 })
        .onClick(() => this.retry())
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}