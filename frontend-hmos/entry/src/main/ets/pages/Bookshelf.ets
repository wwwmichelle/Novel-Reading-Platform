import { BookshelfService } from '../api/BookshelfService';
import { ApiError } from '../api/HttpClient';
import { AuthStore } from '../store/AuthStore';
import { Constants } from '../common/Constants';
import { RouterHelper } from '../common/RouterHelper';
import { LoadingState } from '../components/LoadingState';
import { ErrorState } from '../components/ErrorState';
import { EmptyState } from '../components/EmptyState';
import { BookshelfItem } from '../model/ApiModels';
import promptAction from '@ohos.promptAction';

/**
 * 书架页
 */
@Entry
@Component
struct Bookshelf {
  @State items: BookshelfItem[] = [];
  @State loading: boolean = true;
  @State error: string = '';
  @State loggedIn: boolean = false;

  aboutToAppear(): void {
    this.loggedIn = AuthStore.isLoggedIn();
    if (this.loggedIn) {
      this.loadData();
    } else {
      this.loading = false;
    }
  }

  onPageShow(): void {
    const wasLoggedIn: boolean = this.loggedIn;
    this.loggedIn = AuthStore.isLoggedIn();
    if (this.loggedIn && !wasLoggedIn) {
      this.loadData();
    } else if (!this.loggedIn && wasLoggedIn) {
      this.items = [];
    }
  }

  private async loadData(): Promise<void> {
    this.loading = true;
    this.error = '';
    try {
      this.items = await BookshelfService.list();
    } catch (e) {
      if (e instanceof ApiError) {
        this.error = e.message;
      } else {
        this.error = '加载失败，请检查网络';
      }
    } finally {
      this.loading = false;
    }
  }

  private async removeItem(bookId: string): Promise<void> {
    try {
      await BookshelfService.remove(bookId);
      this.items = this.items.filter((item: BookshelfItem): boolean => item.book_id !== bookId);
      promptAction.showToast({ message: '已移出书架' });
    } catch (e) {
      if (e instanceof ApiError) {
        promptAction.showToast({ message: e.message });
      } else {
        promptAction.showToast({ message: '移出失败' });
      }
    }
  }


  build() {
    Column() {
      // 导航栏
      Row() {
        Text('←')
          .fontSize(22)
          .fontColor('#1B2432')
          .onClick(() => RouterHelper.back())
        Text('我的书架')
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

      if (!this.loggedIn) {
        // 未登录
        Column() {
          Text('📚')
            .fontSize(48)
          Text('请先登录查看书架')
            .fontSize(14)
            .fontColor('#8B95A7')
            .margin({ top: 12 })
          Button('去登录')
            .width(120)
            .height(40)
            .type(ButtonType.Capsule)
            .backgroundColor('#2F6BFF')
            .fontColor('#FFFFFF')
            .fontSize(14)
            .margin({ top: 20 })
            .onClick(() => {
              RouterHelper.push(Constants.PAGE_LOGIN);
            })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else if (this.loading) {
        LoadingState({ tip: '加载中...' })
      } else if (this.error.length > 0) {
        ErrorState({ tip: this.error, retry: (): void => { this.loadData(); } })
      } else if (this.items.length === 0) {
        EmptyState({ tip: '书架是空的，去添加喜欢的小说吧' })
      } else {
        Scroll() {
          Column() {
            ForEach(this.items, (item: BookshelfItem) => {
              Row() {
                // 封面
                if (item.cover_url !== null && item.cover_url.length > 0) {
                  Image(item.cover_url)
                    .width(56)
                    .height(74)
                    .borderRadius(4)
                    .objectFit(ImageFit.Cover)
                } else {
                  Column() {
                    Text(item.book_title.length > 0 ? item.book_title.charAt(0) : '?')
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

                // 信息
                Column() {
                  Text(item.book_title)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#1B2432')
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })

                  Text(item.book_author)
                    .fontSize(13)
                    .fontColor('#59647A')
                    .margin({ top: 4 })

                  if (item.last_read_chapter_title !== null) {
                    Text('上次阅读：' + item.last_read_chapter_title)
                      .fontSize(12)
                      .fontColor('#8B95A7')
                      .margin({ top: 4 })
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                  }

                  if (item.added_at.length >= 10) {
                    Text('加入时间：' + item.added_at.substring(0, 10))
                      .fontSize(12)
                      .fontColor('#BBBBBB')
                      .margin({ top: 2 })
                  }
                }
                .layoutWeight(1)
                .margin({ left: 12 })
                .alignItems(HorizontalAlign.Start)

                // 移出按钮
                Text('✕')
                  .fontSize(18)
                  .fontColor('#CCCCCC')
                  .padding(12)
                  .onClick(() => this.removeItem(item.book_id))
              }
              .width('100%')
              .padding(12)
              .alignItems(VerticalAlign.Center)
              .onClick(() => {
                RouterHelper.push(Constants.PAGE_BOOK_DETAIL, { bookId: item.book_id });
              })
              Divider().color('#F0F0F0').strokeWidth(1)
            }, (item: BookshelfItem) => item.id)
          }
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}