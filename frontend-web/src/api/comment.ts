import { request } from './request'
import type { CommentResponse, PageResponse } from '@/types/api'

export const commentApi = {
  list: (bookId: string, page = 1, pageSize = 20) =>
    request.get<PageResponse<CommentResponse>>(`/api/v1/books/${bookId}/comments`, { params: { page, page_size: pageSize } }),
  create: (bookId: string, content: string) =>
    request.post<CommentResponse>(`/api/v1/books/${bookId}/comments`, { content }),
  delete: (commentId: string) =>
    request.delete(`/api/v1/comments/${commentId}`),
}