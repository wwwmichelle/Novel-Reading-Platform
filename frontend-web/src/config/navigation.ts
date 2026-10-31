import type { NavKey } from '@/types/api'

export interface NavItem {
  key: NavKey
  label: string
  to: string
}

export const NAV_ITEMS: readonly NavItem[] = Object.freeze([
  { key: 'home', label: '首页', to: '/' },
  { key: 'category', label: '分类', to: '/categories' },
  { key: 'bookshelf', label: '书架', to: '/bookshelf' },
  { key: 'profile', label: '我的', to: '/profile' },
])

interface RouteLike {
  name?: string | symbol | null
  path: string
  meta?: { nav?: NavKey }
}

export function resolveActiveNav(route: RouteLike): NavKey | null {
  if (route.name === 'login' || route.name === 'register') return null
  if (route.meta?.nav) return route.meta.nav
  if (route.path.startsWith('/books')) return 'home'
  if (route.path.startsWith('/categories')) return 'category'
  if (route.path.startsWith('/bookshelf')) return 'bookshelf'
  if (route.path.startsWith('/profile')) return 'profile'
  return 'home'
}