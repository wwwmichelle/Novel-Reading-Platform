import common from '@ohos.app.ability.common';
import { BookService } from '../api/BookService';
import { CommentService } from '../api/CommentService';
import { BookshelfService } from '../api/BookshelfService';
import { ApiError } from '../api/HttpClient';
import { AuthStore } from '../store/AuthStore';
import { Constants } from '../common/Constants';
import { RouterHelper } from '../common/RouterHelper';
import { LoadingState } from '../components/LoadingState';
import { ErrorState } from '../components/ErrorState';
import { EmptyState } from '../components/EmptyState';
import {
  BookDetail as BookDetailModel,
  ChapterBrief,
  CommentResponse,
  BookshelfItem,
  PageResponse
} from '../model/ApiModels';
import promptAction from '@ohos.promptAction';

/**
 * 图书详情页（含评论）
 */
@Entry
@Component
struct BookDetail {
  @State bookId: string = '';
  @State book: BookDetailModel | null = null;
  @State comments: CommentResponse[] = [];
  @State loading: boolean = true;
  @State error: string = '';
  @State inBookshelf: boolean = false;
  @State commentInput: string = '';
  @State submittingComment: boolean = false;
  @State commentPage: number = 1;
  @State commentTotalPages: number = 1;
  @State loadingMoreComments: boolean = false;

  aboutToAppear(): void {
    this.bookId = RouterHelper.getParam('bookId');
    this.loadData();
  }

  private async loadData(): Promise<void> {
    this.loading = true;
    this.error = '';
    try {
      this.book = await BookService.detail(this.bookId);
      // 加载评论
      try {
        const resp: PageResponse<CommentResponse> = await CommentService.list(this.bookId, 1);
        this.comments = resp.items;
        this.commentTotalPages = resp.total_pages;
      } catch (e) {
        // 评论加载失败不阻塞
      }
      // 检查书架状态
      if (AuthStore.isLoggedIn()) {
        try {
          const shelf: BookshelfItem[] = await BookshelfService.list();
          this.inBookshelf = shelf.some((item: BookshelfItem): boolean => item.book_id === this.bookId);
        } catch (e) {
          // 忽略
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

  private async toggleBookshelf(): Promise<void> {
    if (!AuthStore.isLoggedIn()) {
      promptAction.showToast({ message: '请先登录' });
      RouterHelper.push(Constants.PAGE_LOGIN);
      return;
    }
    try {
      if (this.inBookshelf) {
        await BookshelfService.remove(this.bookId);
        this.inBookshelf = false;
        promptAction.showToast({ message: '已移出书架' });
      } else {
        await BookshelfService.add(this.bookId);
        this.inBookshelf = true;
        promptAction.showToast({ message: '已加入书架' });
      }
    } catch (e) {
      if (e instanceof ApiError) {
        promptAction.showToast({ message: e.message });
      } else {
        promptAction.showToast({ message: '操作失败' });
      }
    }
  }

  private async openSource(): Promise<void> {
    const url = this.book?.source_url ?? '';
    if (!/^https:\/\/(www\.dedao\.cn\/ebook\/detail\?id=[A-Za-z0-9]+|e\.dangdang\.com\/touch\/products\/\d+\.html)$/.test(url)) {
      return;
    }
    try {
      const context = getContext(this) as common.UIAbilityContext;
      await context.startAbility({ action: 'ohos.want.action.viewData', uri: url });
    } catch (error) {
      promptAction.showToast({ message: '无法打开浏览器，请稍后重试' });
    }
  }

  private async startReading(): Promise<void> {
    if (this.book?.reading_mode === 'external') {
      await this.openSource();
      return;
    }
    try {
      const chapters: ChapterBrief[] = await BookService.chapters(this.bookId);
      if (chapters.length > 0) {
        RouterHelper.push(Constants.PAGE_READING, {
          bookId: this.bookId,
          chapterId: chapters[0].id
        });
      } else {
        promptAction.showToast({ message: '暂无章节' });
      }
    } catch (e) {
      promptAction.showToast({ message: '获取章节失败' });
    }
  }

  private async submitComment(): Promise<void> {
    if (!AuthStore.isLoggedIn()) {
      promptAction.showToast({ message: '请先登录' });
      RouterHelper.push(Constants.PAGE_LOGIN);
      return;
    }
    const content: string = this.commentInput.trim();
    if (content.length === 0) {
      promptAction.showToast({ message: '评论内容不能为空' });
      return;
    }
    this.submittingComment = true;
    try {
      const comment: CommentResponse = await CommentService.create(this.bookId, content);
      this.comments = [comment].concat(this.comments);
      this.commentInput = '';
      promptAction.showToast({ message: '评论发表成功' });
    } catch (e) {
      if (e instanceof ApiError) {
        promptAction.showToast({ message: e.message });
      } else {
        promptAction.showToast({ message: '评论发表失败' });
      }
    } finally {
      this.submittingComment = false;
    }
  }

  private async deleteComment(commentId: string): Promise<void> {
    try {
      const result = await promptAction.showDialog({
        title: '确认删除',
        message: '确定要删除这条评论吗？',
        buttons: [
          { text: '取消', color: '#59647A' },
          { text: '删除', color: '#FF4D4F' }
        ]
      });
      if (result.index === 1) {
        await CommentService.remove(commentId);
        this.comments = this.comments.filter((c: CommentResponse): boolean => c.id !== commentId);
        promptAction.showToast({ message: '删除成功' });
      }
    } catch (e) {
      promptAction.showToast({ message: '操作失败' });
    }
  }

  private async loadMoreComments(): Promise<void> {
    if (this.loadingMoreComments || this.commentPage >= this.commentTotalPages) {
      return;
    }
    this.loadingMoreComments = true;
    try {
      const nextPage: number = this.commentPage + 1;
      const resp: PageResponse<CommentResponse> = await CommentService.list(this.bookId, nextPage);
      this.comments = this.comments.concat(resp.items);
      this.commentPage = nextPage;
      this.commentTotalPages = resp.total_pages;
    } catch (e) {
      // 静默
    } finally {
      this.loadingMoreComments = false;
    }
  }

  private formatTime(iso: string): string {
    if (iso.length >= 19) {
      return iso.substring(0, 19).replace('T', ' ');
    }
    return iso;
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Text('←')
          .fontSize(22)
          .fontColor('#1B2432')
          .onClick(() => RouterHelper.back())
        Text('图书详情')
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
      } else if (this.book !== null) {
        Scroll() {
          Column() {
            // 图书信息卡片
            Row() {
              if (this.book!.cover_url !== null && this.book!.cover_url.length > 0) {
                Image(this.book!.cover_url)
                  .width(90)
                  .height(120)
                  .borderRadius(6)
                  .objectFit(ImageFit.Cover)
              } else {
                Column() {
                  Text(this.book!.title.length > 0 ? this.book!.title.charAt(0) : '?')
                    .fontSize(32)
                    .fontColor('#FFFFFF')
                }
                .width(90)
                .height(120)
                .backgroundColor('#2F6BFF')
                .borderRadius(6)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
              }

              Column() {
                Text(this.book!.title)
                  .fontSize(18)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#1B2432')
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })

                Text('作者：' + this.book!.author)
                  .fontSize(13)
                  .fontColor('#59647A')
                  .margin({ top: 8 })

                Text('状态：' + (this.book!.serial_status === 'ongoing' ? '连载中' : '已完结'))
                  .fontSize(13)
                  .fontColor('#59647A')
                  .margin({ top: 4 })

                if (this.book!.categories.length > 0) {
                  Text('分类：' + this.book!.categories.join(' / '))
                    .fontSize(13)
                    .fontColor('#59647A')
                    .margin({ top: 4 })
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
              }
              .layoutWeight(1)
              .margin({ left: 16 })
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding(16)
            .alignItems(VerticalAlign.Top)

            // 操作按钮
            Row() {
              Button(this.inBookshelf ? '移出书架' : '加入书架')
                .layoutWeight(1)
                .height(44)
                .type(ButtonType.Normal)
                .borderRadius(8)
                .backgroundColor(this.inBookshelf ? '#F5F7FB' : '#2F6BFF')
                .fontColor(this.inBookshelf ? '#59647A' : '#FFFFFF')
                .fontSize(15)
                .margin({ right: 8 })
                .onClick(() => this.toggleBookshelf())

              Button(this.book?.reading_mode === 'external' ? '源网站' : '查看目录')
                .layoutWeight(1)
                .height(44)
                .type(ButtonType.Normal)
                .borderRadius(8)
                .backgroundColor('#F5F7FB')
                .fontColor('#1B2432')
                .fontSize(15)
                .margin({ left: 8, right: 8 })
                .onClick(() => {
                  if (this.book?.reading_mode === 'external') {
                    this.openSource();
                  } else {
                    RouterHelper.push(Constants.PAGE_CHAPTER_LIST, { bookId: this.bookId });
                  }
                })

              Button(this.book?.reading_mode === 'external' ? '源网站阅读' : '开始阅读')
                .layoutWeight(1)
                .height(44)
                .type(ButtonType.Normal)
                .borderRadius(8)
                .backgroundColor('#2F6BFF')
                .fontColor('#FFFFFF')
                .fontSize(15)
                .margin({ left: 8 })
                .onClick(() => this.startReading())
            }
            .width('100%')
            .padding({ left: 16, right: 16 })

            // 简介
            Text('简介')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1B2432')
              .margin({ top: 20, left: 16 })
              .alignSelf(ItemAlign.Start)

            Text(this.book!.description ?? '暂无简介')
              .fontSize(14)
              .lineHeight(22)
              .fontColor('#59647A')
              .margin({ top: 8, left: 16, right: 16 })
              .alignSelf(ItemAlign.Start)

            Divider().color('#E2E8F2').strokeWidth(1).margin({ top: 20 })

            // 评论区
            Text('评论（' + this.comments.length + '）')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1B2432')
              .margin({ top: 16, left: 16 })
              .alignSelf(ItemAlign.Start)

            // 评论输入
            TextArea({ placeholder: '写下你的评论...', text: this.commentInput })
              .width('100%')
              .height(80)
              .fontSize(14)
              .borderRadius(8)
              .backgroundColor('#F5F7FB')
              .margin({ top: 8, left: 16, right: 16 })
              .onChange((value: string) => {
                this.commentInput = value;
              })

            Button(this.submittingComment ? '发表中...' : '发表评论')
              .width(100)
              .height(36)
              .type(ButtonType.Normal)
              .borderRadius(6)
              .backgroundColor('#2F6BFF')
              .fontColor('#FFFFFF')
              .fontSize(14)
              .margin({ top: 8, right: 16 })
              .alignSelf(ItemAlign.End)
              .enabled(!this.submittingComment && this.commentInput.trim().length > 0)
              .onClick(() => this.submitComment())

            // 评论列表
            if (this.comments.length === 0) {
              Text('暂无评论，快来发表第一条评论吧')
                .fontSize(13)
                .fontColor('#8B95A7')
                .margin({ top: 24 })
            } else {
              ForEach(this.comments, (comment: CommentResponse) => {
                Column() {
                  Row() {
                    Text(comment.username.length > 0 ? comment.username : '匿名用户')
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#1B2432')
                    Blank()
                    Text(this.formatTime(comment.created_at))
                      .fontSize(12)
                      .fontColor('#8B95A7')
                  }
                  .width('100%')

                  Text(comment.content)
                    .fontSize(14)
                    .fontColor('#555555')
                    .lineHeight(20)
                    .margin({ top: 6 })

                  if (comment.user_id === AuthStore.userId) {
                    Text('删除')
                      .fontSize(12)
                      .fontColor('#FF4D4F')
                      .margin({ top: 6 })
                      .alignSelf(ItemAlign.End)
                      .onClick(() => this.deleteComment(comment.id))
                  }
                }
                .width('100%')
                .padding(16)
                Divider().color('#F0F0F0').strokeWidth(1)
              }, (comment: CommentResponse) => comment.id)

              if (this.commentPage < this.commentTotalPages) {
                Button(this.loadingMoreComments ? '加载中...' : '加载更多评论')
                  .width('60%')
                  .height(40)
                  .type(ButtonType.Normal)
                  .borderRadius(8)
                  .backgroundColor('#F5F7FB')
                  .fontColor('#59647A')
                  .fontSize(14)
                  .margin({ top: 12, bottom: 16 })
                  .enabled(!this.loadingMoreComments)
                  .onClick(() => this.loadMoreComments())
              }
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