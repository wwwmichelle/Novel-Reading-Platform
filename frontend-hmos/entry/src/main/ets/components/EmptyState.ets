/**
 * 空数据状态组件
 */
@Component
export struct EmptyState {
  @Prop tip: string = '暂无数据';

  build() {
    Column() {
      Text('📭')
        .fontSize(48)
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