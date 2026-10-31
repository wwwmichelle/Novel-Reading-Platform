import { request } from './request'
import type { CategoryBrief, BookSummary, PageResponse } from '@/types/api'

export const categoryApi = {
  list: () => request.get<CategoryBrief[]>('/api/v1/categories'),
  books: (categoryId: string, page = 1, pageSize = 20) =>
    request.get<PageResponse<BookSummary>>(`/api/v1/categories/${categoryId}/books`, { params: { page, page_size: pageSize } }),
}