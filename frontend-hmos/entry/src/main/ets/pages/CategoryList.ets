import { BookService } from '../api/BookService';
import { ApiError } from '../api/HttpClient';
import { Constants } from '../common/Constants';
import { RouterHelper } from '../common/RouterHelper';
import { LoadingState } from '../components/LoadingState';
import { ErrorState } from '../components/ErrorState';
import { EmptyState } from '../components/EmptyState';
import { CategoryBrief } from '../model/ApiModels';

/**
 * 分类列表页
 */
@Entry
@Component
struct CategoryList {
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
      this.categories = await BookService.categories();
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
        Text('全部分类')
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
      } else if (this.categories.length === 0) {
        EmptyState({ tip: '暂无分类' })
      } else {
        Scroll() {
          Column() {
            ForEach(this.categories, (cat: CategoryBrief) => {
              Row() {
                Text(cat.name)
                  .fontSize(16)
                  .fontColor('#1B2432')
                Blank()
                Text('>')
                  .fontSize(16)
                  .fontColor('#CCCCCC')
              }
              .width('100%')
              .height(52)
              .padding({ left: 16, right: 16 })
              .alignItems(VerticalAlign.Center)
              .onClick(() => {
                RouterHelper.push(Constants.PAGE_CATEGORY_BOOKS, {
                  categoryId: cat.id,
                  categoryName: cat.name
                });
              })
              Divider().color('#F0F0F0').strokeWidth(1)
            }, (cat: CategoryBrief) => cat.id)
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