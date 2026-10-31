/**
 * 加载中状态组件
 */
@Component
export struct LoadingState {
  @Prop tip: string = '加载中...';

  build() {
    Column() {
      LoadingProgress()
        .width(48)
        .height(48)
        .color('#2F6BFF')
      Text(this.tip)
        .fontSize(14)
        .fontColor('#8B95A7')
        .margin({ top: 12 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}