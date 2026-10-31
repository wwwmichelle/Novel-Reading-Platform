import { HttpClient } from './HttpClient';
import { Constants } from '../common/Constants';
import {
  CommentResponse,
  CommentCreateRequest,
  PageResponse
} from '../model/ApiModels';

/**
 * 评论相关 API
 */
export class CommentService {
  /** 评论列表（分页） */
  static list(bookId: string, page: number = 1, pageSize: number = Constants.DEFAULT_PAGE_SIZE): Promise<PageResponse<CommentResponse>> {
    const query: Record<string, string> = {
      'page': page.toString(),
      'page_size': pageSize.toString()
    };
    return HttpClient.get<PageResponse<CommentResponse>>('/api/v1/books/' + bookId + '/comments', false, query);
  }

  /** 发表评论（需登录） */
  static create(bookId: string, content: string): Promise<CommentResponse> {
    const body: CommentCreateRequest = { content: content };
    return HttpClient.post<CommentResponse>('/api/v1/books/' + bookId + '/comments', JSON.stringify(body), true);
  }

  /** 删除评论（需登录） */
  static remove(commentId: string): Promise<void> {
    return HttpClient.delete<void>('/api/v1/comments/' + commentId, true);
  }
}