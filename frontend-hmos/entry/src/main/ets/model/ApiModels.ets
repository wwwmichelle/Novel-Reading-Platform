/**
 * API 数据模型定义
 * 对应后端 schemas 中的所有接口类型
 */

/** 用户信息 */
export interface UserResponse {
  id: string;
  username: string;
  role: string;
  created_at: string;
}

/** 令牌响应 */
export interface TokenResponse {
  access_token: string;
  refresh_token: string;
  token_type: string;
  expires_in: number;
}

/** 图书摘要（列表项） */
export interface BookSummary {
  id: string;
  title: string;
  author: string;
  cover_url: string | null;
  serial_status: string;
  latest_chapter_title: string | null;
  is_demo: boolean;
  updated_at: string;
}

/** 图书详情 */
export interface BookDetail {
  source_url?: string;
  source_name?: string;
  reading_mode?: string;
  id: string;
  title: string;
  author: string;
  cover_url: string | null;
  description: string | null;
  serial_status: string;
  latest_chapter_title: string | null;
  is_demo: boolean;
  categories: string[];
  updated_at: string;
}

/** 章节摘要（目录项） */
export interface ChapterBrief {
  id: string;
  title: string;
  order: number;
  word_count: number;
}

/** 章节正文 */
export interface ChapterContent {
  id: string;
  title: string;
  content: string;
  order: number;
  word_count: number;
  prev_chapter_id: string | null;
  next_chapter_id: string | null;
  is_demo: boolean;
}

/** 分类摘要 */
export interface CategoryBrief {
  id: string;
  name: string;
}

/** 评论响应 */
export interface CommentResponse {
  id: string;
  book_id: string;
  user_id: string;
  username: string;
  content: string;
  created_at: string;
}

/** 书架项 */
export interface BookshelfItem {
  id: string;
  book_id: string;
  book_title: string;
  book_author: string;
  cover_url: string | null;
  last_read_chapter_id: string | null;
  last_read_chapter_title: string | null;
  last_read_time: string | null;
  added_at: string;
}

/** 阅读进度响应 */
export interface ReadingProgressResponse {
  book_id: string;
  chapter_id: string;
  chapter_order: number;
  scroll_position: number;
  updated_at: string;
}

/** 分页响应（泛型） */
export interface PageResponse<T> {
  items: T[];
  total: number;
  page: number;
  page_size: number;
  total_pages: number;
}

/** 最近更新响应 */
export interface RecentUpdateResponse<T> {
  items: T[];
  total: number;
}

/** 错误响应 */
export interface ErrorResponse {
  code: string;
  message: string;
  detail: Record<string, string>;
}

/** 注册请求 */
export interface RegisterRequest {
  username: string;
  password: string;
}

/** 登录请求 */
export interface LoginRequest {
  username: string;
  password: string;
}

/** 刷新令牌请求 */
export interface RefreshRequest {
  refresh_token: string;
}

/** 创建评论请求 */
export interface CommentCreateRequest {
  content: string;
}

/** 上报阅读进度请求 */
export interface ProgressReportRequest {
  chapter_id: string;
  chapter_order: number;
  scroll_position: number;
  client_timestamp: string;
}