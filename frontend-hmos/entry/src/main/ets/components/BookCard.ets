/**
 * 图书卡片组件
 * 使用基本类型 @Prop 确保数据同步可靠
 */
@Component
export struct BookCard {
  @Prop bookId: string = '';
  @Prop bookTitle: string = '';
  @Prop bookAuthor: string = '';
  @Prop coverUrl: string = '';
  @Prop latestChapterTitle: string = '';
  @Prop serialStatus: string = '';
  onTap: (bookId: string) => void = (id: string): void => {};

  build() {
    Row() {
      // 封面图
      if (this.coverUrl.length > 0) {
        Image(this.coverUrl)
          .width(56)
          .height(74)
          .borderRadius(4)
          .objectFit(ImageFit.Cover)
      } else {
        Column() {
          Text(this.bookTitle.length > 0 ? this.bookTitle.charAt(0) : '?')
            .fontSize(24)
            .fontColor('#FFFFFF')
        }
        .width(56)
        .height(74)
        .backgroundColor('#2F6BFF')
        .borderRadius(4)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }

      // 图书信息
      Column() {
        Text(this.bookTitle)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1B2432')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(this.bookAuthor)
          .fontSize(13)
          .fontColor('#59647A')
          .margin({ top: 4 })

        if (this.latestChapterTitle.length > 0) {
          Text('最新：' + this.latestChapterTitle)
            .fontSize(12)
            .fontColor('#8B95A7')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 4 })
        }
      }
      .layoutWeight(1)
      .margin({ left: 12 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(12)
    .onClick(() => this.onTap(this.bookId))
  }
}