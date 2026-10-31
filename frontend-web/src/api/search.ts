import { request } from './request'
import type { BookSummary, PageResponse } from '@/types/api'

export const searchApi = {
  search: (keyword: string, scope = 'both', page = 1, pageSize = 20, signal?: AbortSignal) =>
    request.get<PageResponse<BookSummary>>('/api/v1/search', {
      params: { keyword, scope, page, page_size: pageSize },
      signal,
    }),
}