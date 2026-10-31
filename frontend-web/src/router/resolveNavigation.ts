import type { SessionStatus } from '@/types/api'
import { sanitizeRedirect } from '@/utils/url'

export interface GuardRoute {
  meta?: { public?: boolean; requiresAuth?: boolean }
  fullPath: string
  query?: Record<string, unknown>
}

export interface GuardSession {
  status: SessionStatus
  hasRefreshToken: boolean
}

export type GuardLocation =
  | { name: 'login'; query: { redirect: string } }
  | { path: string }

export type GuardResult = { type: 'allow' } | { type: 'redirect'; location: GuardLocation }

export function resolveNavigation(to: GuardRoute, session: GuardSession): GuardResult {
  const isPublic = Boolean(to.meta?.public)

  if (isPublic) {
    if (session.status === 'authenticated') {
      const redirect = sanitizeRedirect(to.query?.redirect)
      return { type: 'redirect', location: redirect ? { path: redirect } : { path: '/' } }
    }
    return { type: 'allow' }
  }

  if (!to.meta?.requiresAuth) return { type: 'allow' }

  if (session.status === 'authenticated') return { type: 'allow' }

  if (session.status === 'anonymous' || session.status === 'invalidated') {
    return {
      type: 'redirect',
      location: { name: 'login', query: { redirect: to.fullPath } },
    }
  }

  return session.hasRefreshToken
    ? { type: 'allow' }
    : { type: 'redirect', location: { name: 'login', query: { redirect: to.fullPath } } }
}
