import { HttpClient } from './HttpClient';
import { BookshelfItem } from '../model/ApiModels';

/**
 * 书架相关 API（均需登录）
 */
export class BookshelfService {
  /** 书架列表 */
  static list(): Promise<BookshelfItem[]> {
    return HttpClient.get<BookshelfItem[]>('/api/v1/bookshelf', true);
  }

  /** 加入书架 */
  static add(bookId: string): Promise<void> {
    return HttpClient.post<void>('/api/v1/bookshelf/' + bookId, null, true);
  }

  /** 移出书架 */
  static remove(bookId: string): Promise<void> {
    return HttpClient.delete<void>('/api/v1/bookshelf/' + bookId, true);
  }
}