import { HttpClient } from './HttpClient';
import {
  ReadingProgressResponse,
  ProgressReportRequest
} from '../model/ApiModels';

/**
 * 阅读进度相关 API（均需登录）
 */
export class ReadingService {
  /** 上报阅读进度 */
  static report(bookId: string, chapterId: string, chapterOrder: number, scrollPosition: number): Promise<void> {
    const body: ProgressReportRequest = {
      chapter_id: chapterId,
      chapter_order: chapterOrder,
      scroll_position: scrollPosition,
      client_timestamp: new Date().toISOString()
    };
    return HttpClient.put<void>('/api/v1/reading-progress/' + bookId, JSON.stringify(body), true);
  }

  /** 获取阅读进度 */
  static get(bookId: string): Promise<ReadingProgressResponse> {
    return HttpClient.get<ReadingProgressResponse>('/api/v1/reading-progress/' + bookId, true);
  }
}