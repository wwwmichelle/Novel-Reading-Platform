import { BookService } from '../api/BookService';
import { ApiError } from '../api/HttpClient';
import { AuthStore } from '../store/AuthStore';
import { Constants } from '../common/Constants';
import { RouterHelper } from '../common/RouterHelper';
import { LoadingState } from '../components/LoadingState';
import { ErrorState } from '../components/ErrorState';
import { BookCard } from '../components/BookCard';
import { BookSummary, CategoryBrief } from '../model/ApiModels';

/**
 * 首页：最近更新 + 分类入口 + 导航
 */
@Entry
@Component
struct Home {
  @State recentBooks: BookSummary[] = [];
  @State categories: CategoryBrief[] = [];
  @State loading: boolean = true;
  @State error: string = '';

  aboutToAppear(): void {
    this.loadData();
  }

  private async loadData(): Promise<void> {
    this.loading = true;
    this.error = '';
    try {
      const recent = await BookService.recent(10);
      this.recentBooks = recent.items;
      const cats = await BookService.categories();
      this.categories = cats;
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

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('小说阅读')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1B2432')
        Blank()
        Text('🔍')
          .fontSize(22)
          .margin({ right: 16 })
          .onClick(() => {
            RouterHelper.push(Constants.PAGE_SEARCH);
          })
        Text('📚')
          .fontSize(22)
          .margin({ right: 16 })
          .onClick(() => {
            if (AuthStore.isLoggedIn()) {
              RouterHelper.push(Constants.PAGE_BOOKSHELF);
            } else {
              RouterHelper.push(Constants.PAGE_LOGIN);
            }
          })
        Text('👤')
          .fontSize(22)
          .onClick(() => {
            RouterHelper.push(Constants.PAGE_PROFILE);
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#FFFFFF')

      Divider().color('#E2E8F2').strokeWidth(1)

      // 内容区域
      if (this.loading) {
        LoadingState({ tip: '加载中...' })
      } else if (this.error.length > 0) {
        ErrorState({ tip: this.error, retry: (): void => { this.loadData(); } })
      } else {
        Scroll() {
          Column() {
            // 分类入口
            Text('分类')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1B2432')
              .margin({ top: 16, left: 16, bottom: 12 })
              .alignSelf(ItemAlign.Start)

            Scroll() {
              Row() {
                ForEach(this.categories, (cat: CategoryBrief) => {
                  Text(cat.name)
                    .fontSize(14)
                    .fontColor('#2F6BFF')
                    .padding({ left: 14, right: 14, top: 6, bottom: 6 })
                    .backgroundColor('#EAF0FF')
                    .borderRadius(16)
                    .margin({ right: 8 })
                    .onClick(() => {
                      RouterHelper.push(Constants.PAGE_CATEGORY_BOOKS, {
                        categoryId: cat.id,
                        categoryName: cat.name
                      });
                    })
                }, (cat: CategoryBrief) => cat.id)
              }
              .padding({ left: 16, right: 16 })
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')

            // 查看全部分类
            Text('查看全部分类 >')
              .fontSize(13)
              .fontColor('#8B95A7')
              .margin({ top: 8, right: 16 })
              .alignSelf(ItemAlign.End)
              .onClick(() => {
                RouterHelper.push(Constants.PAGE_CATEGORY_LIST);
              })

            // 最近更新
            Text('最近更新')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1B2432')
              .margin({ top: 24, left: 16, bottom: 8 })
              .alignSelf(ItemAlign.Start)

            ForEach(this.recentBooks, (item: BookSummary) => {
              BookCard({
                bookId: item.id,
                bookTitle: item.title,
                bookAuthor: item.author,
                coverUrl: item.cover_url ?? '',
                latestChapterTitle: item.latest_chapter_title ?? '',
                serialStatus: item.serial_status,
                onTap: (bookId: string): void => {
                  RouterHelper.push(Constants.PAGE_BOOK_DETAIL, { bookId: bookId });
                }
              })
              Divider().color('#F0F0F0').strokeWidth(1)
            }, (item: BookSummary) => item.id)
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