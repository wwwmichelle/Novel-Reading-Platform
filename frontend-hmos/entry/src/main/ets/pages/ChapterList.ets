import { BookService } from '../api/BookService';
import { ApiError } from '../api/HttpClient';
import { Constants } from '../common/Constants';
import { RouterHelper } from '../common/RouterHelper';
import { LoadingState } from '../components/LoadingState';
import { ErrorState } from '../components/ErrorState';
import { EmptyState } from '../components/EmptyState';
import { ChapterBrief } from '../model/ApiModels';

/**
 * 章节目录页
 */
@Entry
@Component
struct ChapterList {
  @State bookId: string = '';
  @State chapters: ChapterBrief[] = [];
  @State loading: boolean = true;
  @State error: string = '';

  aboutToAppear(): void {
    this.bookId = RouterHelper.getParam('bookId');
    this.loadData();
  }

  private async loadData(): Promise<void> {
    this.loading = true;
    this.error = '';
    try {
      this.chapters = await BookService.chapters(this.bookId);
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
      // 导航栏
      Row() {
        Text('←')
          .fontSize(22)
          .fontColor('#1B2432')
          .onClick(() => RouterHelper.back())
        Text('目录（' + this.chapters.length + ' 章）')
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

      if (this.loading) {
        LoadingState({ tip: '加载中...' })
      } else if (this.error.length > 0) {
        ErrorState({ tip: this.error, retry: (): void => { this.loadData(); } })
      } else if (this.chapters.length === 0) {
        EmptyState({ tip: '暂无章节' })
      } else {
        Scroll() {
          Column() {
            ForEach(this.chapters, (chapter: ChapterBrief) => {
              Row() {
                Text(chapter.order + '. ' + chapter.title)
                  .fontSize(15)
                  .fontColor('#1B2432')
                  .layoutWeight(1)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                if (chapter.word_count > 0) {
                  Text(chapter.word_count + '字')
                    .fontSize(12)
                    .fontColor('#8B95A7')
                    .margin({ left: 8 })
                }
              }
              .width('100%')
              .height(52)
              .padding({ left: 16, right: 16 })
              .alignItems(VerticalAlign.Center)
              .onClick(() => {
                RouterHelper.push(Constants.PAGE_READING, {
                  bookId: this.bookId,
                  chapterId: chapter.id
                });
              })
              Divider().color('#F0F0F0').strokeWidth(1)
            }, (chapter: ChapterBrief) => chapter.id)
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