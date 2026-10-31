import { request } from './request'
import type { BookSummary, BookDetail, ChapterBrief, ChapterContent, PageResponse } from '@/types/api'

export const bookApi = {
  list: (page = 1, pageSize = 20, signal?: AbortSignal) =>
    request.get<PageResponse<BookSummary>>('/api/v1/books', { params: { page, page_size: pageSize }, signal }),
  recent: (limit = 10) =>
    request.get<{ items: BookSummary[]; total: number }>('/api/v1/books/recent', { params: { limit } }),
  detail: (bookId: string) =>
    request.get<BookDetail>(`/api/v1/books/${bookId}`),
  chapters: (bookId: string) =>
    request.get<ChapterBrief[]>(`/api/v1/books/${bookId}/chapters`),
  chapter: (bookId: string, chapterId: string) =>
    request.get<ChapterContent>(`/api/v1/books/${bookId}/chapters/${chapterId}`),
}