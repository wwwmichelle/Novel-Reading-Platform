import { describe, expect, it } from 'vitest'

import { isSafeImageUrl, isSafeSourceUrl, sanitizeRedirect } from '@/utils/url'

describe('isSafeImageUrl', () => {
  it.each([
    'https://example.com/a.png',
    'http://example.com/b.jpg',
    'HTTPS://EXAMPLE.COM/C.PNG',
  ])('accepts %s', (url) => {
    expect(isSafeImageUrl(url)).toBe(true)
  })

  it.each([
    '//evil.com/a.png',
    'data:image/svg+xml;base64,xxx',
    'javascript:void(0)',
    'vbscript:msgbox(1)',
    'file:///etc/passwd',
    'blob:https://example.com/x',
    'not-a-url',
    '',
    '   ',
  ])('rejects %s', (url) => {
    expect(isSafeImageUrl(url)).toBe(false)
  })

  it('rejects non-string input', () => {
    expect(isSafeImageUrl(null)).toBe(false)
    expect(isSafeImageUrl(undefined)).toBe(false)
    expect(isSafeImageUrl(42)).toBe(false)
  })
})

describe('sanitizeRedirect', () => {
  it('keeps a safe internal path with query and hash', () => {
    expect(sanitizeRedirect('/books/1/read/2?x=1#top')).toBe('/books/1/read/2?x=1#top')
  })

  it('rejects protocol-relative urls', () => {
    expect(sanitizeRedirect('//evil.com')).toBeNull()
  })

  it('rejects absolute urls', () => {
    expect(sanitizeRedirect('http://evil.com/x')).toBeNull()
    expect(sanitizeRedirect('https://evil.com')).toBeNull()
  })

  it('rejects auth pages to avoid redirect loops', () => {
    expect(sanitizeRedirect('/login')).toBeNull()
    expect(sanitizeRedirect('/login?redirect=/x')).toBeNull()
    expect(sanitizeRedirect('/register')).toBeNull()
  })

  it('rejects non-string and relative paths without leading slash', () => {
    expect(sanitizeRedirect(undefined)).toBeNull()
    expect(sanitizeRedirect(1)).toBeNull()
    expect(sanitizeRedirect('books/1')).toBeNull()
  })
})
describe('official literature source links', () => {
  it.each([
    'https://www.dedao.cn/ebook/detail?id=abc123',
    'https://e.dangdang.com/touch/products/1900717559.html',
  ])('accepts %s', url => expect(isSafeSourceUrl(url)).toBe(true))
  it.each([
    'javascript:alert(1)', 'http://www.dedao.cn/ebook/detail?id=abc',
    'https://www.dedao.cn.evil.com/ebook/detail?id=abc',
    'https://evil.com@www.dedao.cn/ebook/detail?id=abc',
    'https://www.dedao.cn/ebook/detail?id=abc&redirect=https://evil.com',
    'https://www.qimao.com/shuku/123/',
  ])('rejects %s', url => expect(isSafeSourceUrl(url)).toBe(false))
})
