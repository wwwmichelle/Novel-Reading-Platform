import { describe, expect, it } from 'vitest'

import { isCanceled, isUnauthorized, toAppError } from '@/utils/errors'

function httpError(status: number, message?: string) {
  return {
    response: { status, data: { message } },
    code: 'ERR_BAD_RESPONSE',
  }
}

describe('toAppError', () => {
  it('maps 401 to unauthorized', () => {
    expect(toAppError(httpError(401)).kind).toBe('unauthorized')
  })

  it('maps forbidden responses to client errors', () => {
    expect(toAppError(httpError(403)).kind).toBe('client')
  })

  it('maps 404 to client', () => {
    expect(toAppError(httpError(404)).kind).toBe('client')
  })

  it('maps 422 to client', () => {
    expect(toAppError(httpError(422)).kind).toBe('client')
  })

  it('maps 500 to server', () => {
    expect(toAppError(httpError(500)).kind).toBe('server')
  })

  it('maps 503 to server', () => {
    expect(toAppError(httpError(503)).kind).toBe('server')
  })

  it('maps missing response to network', () => {
    expect(toAppError({ code: 'ERR_NETWORK' }).kind).toBe('network')
  })

  it('maps timeout to network', () => {
    expect(toAppError({ code: 'ECONNABORTED' }).kind).toBe('network')
  })

  it('uses the server message without leaking credentials', () => {
    const error = toAppError(httpError(500, '服务异常'))
    expect(error.message).toBe('服务异常')
    expect(error.message).not.toMatch(/Bearer|token|password/i)
  })

  it('falls back to a chinese message', () => {
    const error = toAppError(httpError(400))
    expect(error.message.length).toBeGreaterThan(0)
    expect(error.message).not.toMatch(/Bearer|token|password/i)
  })
})

describe('helpers', () => {
  it('detects canceled requests', () => {
    expect(isCanceled({ code: 'ERR_CANCELED' })).toBe(true)
    expect(isCanceled({ code: 'ERR_NETWORK' })).toBe(false)
  })

  it('detects unauthorized errors', () => {
    expect(isUnauthorized(httpError(401))).toBe(true)
    expect(isUnauthorized(httpError(500))).toBe(false)
  })
})