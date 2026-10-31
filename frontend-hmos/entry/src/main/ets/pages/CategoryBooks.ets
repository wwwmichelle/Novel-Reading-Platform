import { BookService } from '../api/BookService';
import { ApiError } from '../api/HttpClient';
import { Constants } from '../common/Constants';
import { RouterHelper } from '../common/RouterHelper';
import { LoadingState } from '../components/LoadingState';
import { ErrorState } from '../components/ErrorState';
import { EmptyState } from '../components/EmptyState';
import { BookCard } from '../components/BookCard';
import { BookSummary, PageResponse } from '../model/ApiModels';

/**
 * 分类下图书页（支持分页加载）
 */
@Entry
@Component
struct CategoryBooks {
  @State categoryId: string = '';
  @State categoryName: string = '分类';
  @State books: BookSummary[] = [];
  @State loading: boolean = true;
  @State loadingMore: boolean = false;
  @State error: string = '';
  @State page: number = 1;
  @State totalPages: number = 1;

  aboutToAppear(): void {
    this.categoryId = RouterHelper.getParam('categoryId');
    this.categoryName = RouterHelper.getParam('categoryName');
    if (this.categoryName.length === 0) {
      this.categoryName = '分类';
    }
    this.loadData();
  }

  private async loadData(): Promise<void> {
    this.loading = true;
    this.error = '';
    this.page = 1;
    try {
      const resp: PageResponse<BookSummary> = await BookService.categoryBooks(this.categoryId, 1);
      this.books = resp.items;
      this.totalPages = resp.total_pages;
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

  private async loadMore(): Promise<void> {
    if (this.loadingMore || this.page >= this.totalPages) {
      return;
    }
    this.loadingMore = true;
    try {
      const nextPage: number = this.page + 1;
      const resp: PageResponse<BookSummary> = await BookService.categoryBooks(this.categoryId, nextPage);
      this.books = this.books.concat(resp.items);
      this.page = nextPage;
      this.totalPages = resp.total_pages;
    } catch (e) {
      // 加载更多失败静默处理
    } finally {
      this.loadingMore = false;
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
        Text(this.categoryName)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1B2432')
          .margin({ left: 12 })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
        Blank()
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#FFFFFF')

      Divider().color('#E2E8F2').strokeWidth(1)

      if (this.loading) {
        LoadingState({ tip: '加载中...' })
      } else if (this.error.length > 0) {
        ErrorState({ tip: this.error, retry: (): void => { this.loadData(); } })
      } else if (this.books.length === 0) {
        EmptyState({ tip: '该分类下暂无图书' })
      } else {
        Scroll() {
          Column() {
            ForEach(this.books, (item: BookSummary) => {
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

            // 加载更多
            if (this.page < this.totalPages) {
              Button(this.loadingMore ? '加载中...' : '加载更多')
                .width('60%')
                .height(40)
                .type(ButtonType.Normal)
                .borderRadius(8)
                .backgroundColor('#F5F7FB')
                .fontColor('#59647A')
                .fontSize(14)
                .margin({ top: 16, bottom: 16 })
                .enabled(!this.loadingMore)
                .onClick(() => this.loadMore())
            } else {
              Text('没有更多了')
                .fontSize(13)
                .fontColor('#CCCCCC')
                .margin({ top: 16, bottom: 16 })
            }
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