import { createMemoryHistory, createRouter } from 'vue-router'
import { describe, expect, it } from 'vitest'

import { resolveNavigation } from '@/router/resolveNavigation'

const controlledPaths = [
  '/',
  '/categories',
  '/categories/cat-wuxia',
  '/books/1',
  '/books/1/chapters',
  '/books/1/read/2',
  '/bookshelf',
  '/profile',
]

describe('resolveNavigation', () => {
  it.each(controlledPaths)('redirects anonymous visitors from %s to login', (path) => {
    const result = resolveNavigation(
      { meta: { requiresAuth: true }, fullPath: path },
      { status: 'anonymous', hasRefreshToken: false },
    )
    expect(result).toEqual({
      type: 'redirect',
      location: { name: 'login', query: { redirect: path } },
    })
  })

  it('allows visitors to browse without redirecting authenticated users', () => {
    for (const status of ['anonymous', 'authenticated'] as const) {
      expect(resolveNavigation({ meta: {}, fullPath: '/categories' },
        { status, hasRefreshToken: false })).toEqual({ type: 'allow' })
    }
  })

  it('allows authenticated users on controlled pages', () => {
    expect(
      resolveNavigation(
        { meta: { requiresAuth: true }, fullPath: '/bookshelf' },
        { status: 'authenticated', hasRefreshToken: true },
      ),
    ).toEqual({ type: 'allow' })
  })

  it('redirects authenticated users away from the login page', () => {
    expect(
      resolveNavigation(
        { meta: { public: true }, fullPath: '/login' },
        { status: 'authenticated', hasRefreshToken: true },
      ),
    ).toEqual({ type: 'redirect', location: { path: '/' } })
  })

  it('honours a safe redirect for authenticated users', () => {
    expect(
      resolveNavigation(
        { meta: { public: true }, fullPath: '/login?redirect=/books/1/read/2', query: { redirect: '/books/1/read/2' } },
        { status: 'authenticated', hasRefreshToken: true },
      ),
    ).toEqual({ type: 'redirect', location: { path: '/books/1/read/2' } })
  })

  it('drops an unsafe redirect', () => {
    expect(
      resolveNavigation(
        { meta: { public: true }, fullPath: '/login?redirect=http://evil.com', query: { redirect: 'http://evil.com' } },
        { status: 'authenticated', hasRefreshToken: true },
      ),
    ).toEqual({ type: 'redirect', location: { path: '/' } })
  })

  it('allows unknown sessions that still hold a refresh token', () => {
    expect(
      resolveNavigation(
        { meta: { requiresAuth: true }, fullPath: '/bookshelf' },
        { status: 'unknown', hasRefreshToken: true },
      ),
    ).toEqual({ type: 'allow' })
  })

  it('is idempotent for invalidated sessions', () => {
    const first = resolveNavigation(
      { meta: { requiresAuth: true }, fullPath: '/profile' },
      { status: 'invalidated', hasRefreshToken: false },
    )
    const second = resolveNavigation(
      { meta: { requiresAuth: true }, fullPath: '/profile' },
      { status: 'invalidated', hasRefreshToken: false },
    )
    expect(first).toEqual(second)
  })

  it('matches the catch-all route for unknown paths', () => {
    const router = createRouter({
      history: createMemoryHistory(),
      routes: [
        { path: '/', name: 'home', component: { template: '<div />' } },
        { path: '/:pathMatch(.*)*', redirect: '/' },
      ],
    })
    expect(router.resolve('/abc/def').matched[0].redirect).toBe('/')
  })
})