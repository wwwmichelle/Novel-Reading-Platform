import { HttpClient } from './HttpClient';
import { Constants } from '../common/Constants';
import {
  BookSummary,
  BookDetail,
  ChapterBrief,
  ChapterContent,
  CategoryBrief,
  PageResponse,
  RecentUpdateResponse
} from '../model/ApiModels';

/**
 * 图书相关 API
 */
export class BookService {
  /** 图书列表（分页） */
  static list(page: number = 1, pageSize: number = Constants.DEFAULT_PAGE_SIZE): Promise<PageResponse<BookSummary>> {
    const query: Record<string, string> = {
      'page': page.toString(),
      'page_size': pageSize.toString()
    };
    return HttpClient.get<PageResponse<BookSummary>>('/api/v1/books', false, query);
  }

  /** 最近更新 */
  static recent(limit: number = 10): Promise<RecentUpdateResponse<BookSummary>> {
    const query: Record<string, string> = { 'limit': limit.toString() };
    return HttpClient.get<RecentUpdateResponse<BookSummary>>('/api/v1/books/recent', false, query);
  }

  /** 图书详情 */
  static detail(bookId: string): Promise<BookDetail> {
    return HttpClient.get<BookDetail>('/api/v1/books/' + bookId, false);
  }

  /** 章节目录 */
  static chapters(bookId: string): Promise<ChapterBrief[]> {
    return HttpClient.get<ChapterBrief[]>('/api/v1/books/' + bookId + '/chapters', false);
  }

  /** 章节正文 */
  static chapter(bookId: string, chapterId: string): Promise<ChapterContent> {
    return HttpClient.get<ChapterContent>('/api/v1/books/' + bookId + '/chapters/' + chapterId, false);
  }

  /** 分类列表 */
  static categories(): Promise<CategoryBrief[]> {
    return HttpClient.get<CategoryBrief[]>('/api/v1/categories', false);
  }

  /** 分类下图书（分页） */
  static categoryBooks(categoryId: string, page: number = 1, pageSize: number = Constants.DEFAULT_PAGE_SIZE): Promise<PageResponse<BookSummary>> {
    const query: Record<string, string> = {
      'page': page.toString(),
      'page_size': pageSize.toString()
    };
    return HttpClient.get<PageResponse<BookSummary>>('/api/v1/categories/' + categoryId + '/books', false, query);
  }

  /** 搜索 */
  static search(keyword: string, scope: string = '', page: number = 1, pageSize: number = Constants.DEFAULT_PAGE_SIZE): Promise<PageResponse<BookSummary>> {
    const query: Record<string, string> = {
      'keyword': keyword,
      'page': page.toString(),
      'page_size': pageSize.toString()
    };
    if (scope.length > 0) {
      query['scope'] = scope;
    }
    return HttpClient.get<PageResponse<BookSummary>>('/api/v1/search', false, query);
  }
}