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
 * 搜索页
 */
@Entry
@Component
struct Search {
  @State keyword: string = '';
  @State results: BookSummary[] = [];
  @State loading: boolean = false;
  @State searched: boolean = false;
  @State error: string = '';
  @State page: number = 1;
  @State totalPages: number = 1;
  @State loadingMore: boolean = false;

  private async doSearch(): Promise<void> {
    const kw: string = this.keyword.trim();
    if (kw.length === 0) {
      return;
    }
    this.loading = true;
    this.error = '';
    this.page = 1;
    try {
      const resp: PageResponse<BookSummary> = await BookService.search(kw, '', 1);
      this.results = resp.items;
      this.totalPages = resp.total_pages;
      this.searched = true;
    } catch (e) {
      if (e instanceof ApiError) {
        this.error = e.message;
      } else {
        this.error = '搜索失败，请重试';
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
      const resp: PageResponse<BookSummary> = await BookService.search(this.keyword.trim(), '', nextPage);
      this.results = this.results.concat(resp.items);
      this.page = nextPage;
      this.totalPages = resp.total_pages;
    } catch (e) {
      // 静默处理
    } finally {
      this.loadingMore = false;
    }
  }

  build() {
    Column() {
      // 导航栏 + 搜索框
      Row() {
        Text('←')
          .fontSize(22)
          .fontColor('#1B2432')
          .onClick(() => RouterHelper.back())
        TextInput({ placeholder: '搜索小说', text: this.keyword })
          .layoutWeight(1)
          .height(40)
          .fontSize(14)
          .borderRadius(20)
          .backgroundColor('#F5F7FB')
          .margin({ left: 12, right: 12 })
          .onChange((value: string) => {
            this.keyword = value;
          })
          .onSubmit((enterKey: EnterKeyType): void => {
            this.doSearch();
          })
        Text('搜索')
          .fontSize(15)
          .fontColor('#2F6BFF')
          .onClick(() => this.doSearch())
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#FFFFFF')

      Divider().color('#E2E8F2').strokeWidth(1)

      // 搜索结果
      if (this.loading) {
        LoadingState({ tip: '搜索中...' })
      } else if (this.error.length > 0) {
        ErrorState({ tip: this.error, retry: (): void => { this.doSearch(); } })
      } else if (this.searched && this.results.length === 0) {
        EmptyState({ tip: '未找到相关小说' })
      } else if (this.searched) {
        Scroll() {
          Column() {
            Text('搜索结果（' + this.results.length + ' 条）')
              .fontSize(13)
              .fontColor('#8B95A7')
              .margin({ top: 12, left: 16 })
              .alignSelf(ItemAlign.Start)

            ForEach(this.results, (item: BookSummary) => {
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
      } else {
        Column() {
          Text('🔍')
            .fontSize(48)
          Text('输入关键词搜索小说')
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
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}