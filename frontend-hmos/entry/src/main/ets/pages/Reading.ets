import { BookService } from '../api/BookService';
import { ReadingService } from '../api/ReadingService';
import { ApiError } from '../api/HttpClient';
import { AuthStore } from '../store/AuthStore';
import { ReadingStore } from '../store/ReadingStore';
import { RouterHelper } from '../common/RouterHelper';
import { LoadingState } from '../components/LoadingState';
import { ErrorState } from '../components/ErrorState';
import { ChapterContent } from '../model/ApiModels';

/**
 * 阅读页
 * - 章节正文展示
 * - 上一章/下一章导航
 * - 字号调整
 * - 日间/夜间主题切换
 * - 阅读进度上报（登录用户）
 */
@Entry
@Component
struct Reading {
  @State bookId: string = '';
  @State chapterId: string = '';
  @State chapter: ChapterContent | null = null;
  @State loading: boolean = true;
  @State error: string = '';
  @State showToolbar: boolean = true;
  @State isDark: boolean = false;
  @State fontSize: number = 18;

  aboutToAppear(): void {
    this.bookId = RouterHelper.getParam('bookId');
    this.chapterId = RouterHelper.getParam('chapterId');
    this.isDark = ReadingStore.isDark();
    this.fontSize = ReadingStore.fontSize;
    this.loadChapter();
  }

  private async loadChapter(): Promise<void> {
    this.loading = true;
    this.error = '';
    try {
      this.chapter = await BookService.chapter(this.bookId, this.chapterId);
      // 登录用户自动上报阅读进度
      if (AuthStore.isLoggedIn() && this.chapter !== null) {
        try {
          await ReadingService.report(this.bookId, this.chapter!.id, this.chapter!.order, 0);
        } catch (e) {
          // 进度上报失败不阻塞阅读
        }
      }
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

  private hasPrevChapter(): boolean {
    return this.chapter !== null && this.chapter!.prev_chapter_id !== null;
  }

  private hasNextChapter(): boolean {
    return this.chapter !== null && this.chapter!.next_chapter_id !== null;
  }

  private prevChapter(): void {
    if (this.hasPrevChapter()) {
      this.chapterId = this.chapter!.prev_chapter_id!;
      this.loadChapter();
    }
  }

  private nextChapter(): void {
    if (this.hasNextChapter()) {
      this.chapterId = this.chapter!.next_chapter_id!;
      this.loadChapter();
    }
  }

  private async decreaseFontSize(): Promise<void> {
    await ReadingStore.decreaseFontSize();
    this.fontSize = ReadingStore.fontSize;
  }

  private async increaseFontSize(): Promise<void> {
    await ReadingStore.increaseFontSize();
    this.fontSize = ReadingStore.fontSize;
  }

  private async toggleTheme(): Promise<void> {
    await ReadingStore.toggleTheme();
    this.isDark = ReadingStore.isDark();
  }

  build() {
    Column() {
      // 顶部工具栏
      if (this.showToolbar) {
        Row() {
          Text('←')
            .fontSize(22)
            .fontColor(this.isDark ? '#CCCCCC' : '#1B2432')
            .onClick(() => RouterHelper.back())
          Text('上一章')
            .fontSize(14)
            .fontColor(this.hasPrevChapter() ? '#2F6BFF' : '#CCCCCC')
            .margin({ left: 16 })
            .onClick(() => this.prevChapter())
          Text('下一章')
            .fontSize(14)
            .fontColor(this.hasNextChapter() ? '#2F6BFF' : '#CCCCCC')
            .margin({ left: 16 })
            .onClick(() => this.nextChapter())
          Blank()
          Text('A-')
            .fontSize(16)
            .fontColor(this.isDark ? '#CCCCCC' : '#1B2432')
            .padding({ left: 8, right: 8 })
            .onClick(() => this.decreaseFontSize())
          Text(this.fontSize.toString())
            .fontSize(14)
            .fontColor(this.isDark ? '#CCCCCC' : '#1B2432')
            .margin({ left: 4, right: 4 })
          Text('A+')
            .fontSize(16)
            .fontColor(this.isDark ? '#CCCCCC' : '#1B2432')
            .padding({ left: 8, right: 8 })
            .onClick(() => this.increaseFontSize())
          Text(this.isDark ? '日间' : '夜间')
            .fontSize(14)
            .fontColor('#2F6BFF')
            .margin({ left: 8 })
            .onClick(() => this.toggleTheme())
        }
        .width('100%')
        .height(48)
        .padding({ left: 16, right: 16 })
        .alignItems(VerticalAlign.Center)
        .backgroundColor(this.isDark ? '#262626' : '#FFFFFF')

        Divider().color(this.isDark ? '#1B2432' : '#E2E8F2').strokeWidth(1)
      }

      // 内容区域
      if (this.loading) {
        LoadingState({ tip: '加载中...' })
      } else if (this.error.length > 0) {
        ErrorState({ tip: this.error, retry: (): void => { this.loadChapter(); } })
      } else if (this.chapter !== null) {
        Scroll() {
          Column() {
            // 章节标题
            Text(this.chapter!.title)
              .fontSize(22)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.isDark ? '#E0E0E0' : '#1B2432')
              .margin({ top: 24, bottom: 20 })
              .textAlign(TextAlign.Center)
              .width('100%')

            // 章节正文（Text 默认不解析 HTML，XSS 安全）
            Text(this.chapter!.content)
              .fontSize(this.fontSize)
              .lineHeight(this.fontSize * 1.8)
              .fontColor(this.isDark ? '#CCCCCC' : '#1B2432')
              .textAlign(TextAlign.Start)
              .width('100%')
              .margin({ bottom: 40 })
          }
          .width('100%')
          .padding({ left: 20, right: 20 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .onClick(() => {
          this.showToolbar = !this.showToolbar;
        })
      }

      // 底部导航
      if (this.showToolbar && this.chapter !== null) {
        Divider().color(this.isDark ? '#1B2432' : '#E2E8F2').strokeWidth(1)
        Row() {
          Button('上一章')
            .layoutWeight(1)
            .height(44)
            .type(ButtonType.Normal)
            .borderRadius(8)
            .backgroundColor(this.isDark ? '#1B2432' : '#F5F7FB')
            .fontColor(this.hasPrevChapter() ? (this.isDark ? '#CCCCCC' : '#1B2432') : '#CCCCCC')
            .fontSize(15)
            .enabled(this.hasPrevChapter())
            .margin({ right: 8 })
            .onClick(() => this.prevChapter())

          Button('下一章')
            .layoutWeight(1)
            .height(44)
            .type(ButtonType.Normal)
            .borderRadius(8)
            .backgroundColor('#2F6BFF')
            .fontColor('#FFFFFF')
            .fontSize(15)
            .enabled(this.hasNextChapter())
            .margin({ left: 8 })
            .onClick(() => this.nextChapter())
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .backgroundColor(this.isDark ? '#262626' : '#FFFFFF')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.isDark ? '#1A1A1A' : '#FFFFFF')
  }
}