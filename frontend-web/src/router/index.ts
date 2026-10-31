import { createRouter, createWebHistory } from 'vue-router'

import type { NavKey } from '@/types/api'
import { useAuthStore } from '@/stores/auth'
import { getTokens } from '@/utils/session'
import { resolveNavigation } from './resolveNavigation'

declare module 'vue-router' {
  interface RouteMeta {
    public?: boolean
    requiresAuth?: boolean
    nav?: NavKey
    title?: string
  }
}

function normalizeKeyword(value: unknown): string {
  if (typeof value !== 'string') return ''
  return value.trim().slice(0, 50)
}

function normalizeScope(value: unknown): 'title' | 'author' | 'both' {
  return value === 'title' || value === 'author' || value === 'both' ? value : 'both'
}

function normalizePage(value: unknown): number {
  const page = Number(value)
  return Number.isInteger(page) && page > 0 ? page : 1
}

const router = createRouter({
  history: createWebHistory(),
  scrollBehavior(to, _from, savedPosition) {
    if (savedPosition) return savedPosition
    if (to.hash) return { el: to.hash, behavior: 'smooth' }
    return { top: 0 }
  },
  routes: [
    { path: '/login', name: 'login', component: () => import('@/views/LoginView.vue'), meta: { public: true, title: '登录' } },
    { path: '/register', name: 'register', component: () => import('@/views/RegisterView.vue'), meta: { public: true, title: '注册' } },
    {
      path: '/search',
      redirect: (to) => {
        const keyword = normalizeKeyword(to.query.keyword)
        if (!keyword) return { path: '/' }
        return {
          path: '/',
          query: {
            keyword,
            scope: normalizeScope(to.query.scope),
            page: String(normalizePage(to.query.page)),
          },
        }
      },
    },
    { path: '/', name: 'home', component: () => import('@/views/HomeView.vue'), meta: { nav: 'home', title: '书目浏览' } },
    { path: '/categories', name: 'categories', component: () => import('@/views/CategoryListView.vue'), meta: { nav: 'category', title: '全部分类' } },
    { path: '/categories/:categoryId', name: 'category-books', component: () => import('@/views/CategoryBooksView.vue'), meta: { nav: 'category', title: '分类图书' } },
    { path: '/books/:bookId', name: 'book-detail', component: () => import('@/views/BookDetailView.vue'), meta: { nav: 'home', title: '图书详情' } },
    { path: '/books/:bookId/chapters', name: 'chapter-list', component: () => import('@/views/ChapterListView.vue'), meta: { nav: 'home', title: '章节目录' } },
    { path: '/books/:bookId/read/:chapterId', name: 'reading', component: () => import('@/views/ReadingView.vue'), meta: { nav: 'home', title: '阅读' } },
    { path: '/bookshelf', name: 'bookshelf', component: () => import('@/views/BookshelfView.vue'), meta: { requiresAuth: true, nav: 'bookshelf', title: '我的书架' } },
    { path: '/profile', name: 'profile', component: () => import('@/views/ProfileView.vue'), meta: { requiresAuth: true, nav: 'profile', title: '个人中心' } },
    { path: '/:pathMatch(.*)*', redirect: '/' },
  ],
})

router.beforeEach(async (to) => {
  const authStore = useAuthStore()
  if (authStore.status === 'unknown') {
    await authStore.bootstrap()
  }

  const { refresh } = getTokens()
  const result = resolveNavigation(
    {
      meta: { public: to.meta.public, requiresAuth: to.meta.requiresAuth },
      fullPath: to.fullPath,
      query: to.query,
    },
    { status: authStore.status, hasRefreshToken: Boolean(refresh) },
  )

  if (result.type === 'allow') return true
  return result.location
})

export default router
