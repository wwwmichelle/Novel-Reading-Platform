import type { AppErrorKind } from '@/utils/errors'

export interface UserResponse {
  id: string
  username: string
  role: string
  created_at: string
}

export interface TokenResponse {
  access_token: string
  refresh_token: string
  token_type: string
  expires_in: number
}

export interface BookSummary {
  id: string
  title: string
  author: string
  cover_url: string | null
  serial_status: string
  latest_chapter_title: string | null
  source_url?: string | null
  source_name?: string | null
  reading_mode?: 'internal' | 'external'
  is_demo: boolean
  updated_at: string
}

export interface BookDetail {
  id: string
  title: string
  author: string
  cover_url: string | null
  description: string | null
  serial_status: string
  latest_chapter_title: string | null
  source_url?: string | null
  source_name?: string | null
  reading_mode?: 'internal' | 'external'
  is_demo: boolean
  categories: string[]
  updated_at: string
}

export interface ChapterBrief {
  id: string
  title: string
  order: number
  word_count: number
}

export interface ChapterContent {
  id: string
  title: string
  content: string
  order: number
  word_count: number
  prev_chapter_id: string | null
  next_chapter_id: string | null
  is_demo: boolean
}

export interface CategoryBrief {
  id: string
  name: string
}

export interface CommentResponse {
  id: string
  book_id: string
  user_id: string
  username: string
  content: string
  created_at: string
}

export interface BookshelfItem {
  id: string
  book_id: string
  book_title: string
  book_author: string
  cover_url: string | null
  last_read_chapter_id: string | null
  last_read_chapter_title: string | null
  last_read_time: string | null
  added_at: string
}

export interface ReadingProgressResponse {
  book_id: string
  chapter_id: string
  chapter_order: number
  scroll_position: number
  updated_at: string
}

export interface PageResponse<T> {
  items: T[]
  total: number
  page: number
  page_size: number
  total_pages: number
}

export interface ErrorResponse {
  code: string
  message: string
  detail: Record<string, unknown>
}

export type SessionStatus = 'unknown' | 'authenticated' | 'anonymous' | 'invalidated'

export type NavKey = 'home' | 'category' | 'bookshelf' | 'profile'

export type SearchScope = 'title' | 'author' | 'both'

export interface SearchQuery {
  keyword: string
  scope: SearchScope
  page: number
}

export type CoverKind = 'remote' | 'builtin' | 'placeholder'

export interface CoverRef {
  kind: CoverKind
  src?: string
  title: string
  author: string
  paletteIndex: number
  alt: string
}

export type { AppErrorKind }