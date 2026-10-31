import { request } from './request'
import type { BookshelfItem } from '@/types/api'

export const bookshelfApi = {
  list: () => request.get<BookshelfItem[]>('/api/v1/bookshelf'),
  add: (bookId: string) => request.post(`/api/v1/bookshelf/${bookId}`),
  remove: (bookId: string) => request.delete(`/api/v1/bookshelf/${bookId}`),
}