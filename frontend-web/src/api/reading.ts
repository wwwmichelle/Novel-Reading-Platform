import { request } from './request'
import type { ReadingProgressResponse } from '@/types/api'

export const readingApi = {
  report: (bookId: string, data: { chapter_id: string; chapter_order: number; scroll_position: number; client_timestamp: string }) =>
    request.put<ReadingProgressResponse>(`/api/v1/reading-progress/${bookId}`, data),
  get: (bookId: string) =>
    request.get<ReadingProgressResponse>(`/api/v1/reading-progress/${bookId}`),
}