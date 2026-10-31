import { describe, expect, it } from 'vitest'

import { paletteFor, resolveCover } from '@/composables/useCover'
import { COVER_REGISTRY, PLACEHOLDER_PALETTE, normalizeTitle } from '@/config/covers'

describe('resolveCover', () => {
  it('prefers a safe remote url', () => {
    const cover = resolveCover({ title: 'X', author: 'Y', cover_url: 'https://example.com/a.png' })
    expect(cover.kind).toBe('remote')
    expect(cover.src).toBe('https://example.com/a.png')
  })

  it.each(['javascript:void(0)', 'data:image/svg+xml,xxx', '//evil.com/a.png'])(
    'skips unsafe url %s and falls through',
    (url) => {
      const cover = resolveCover({ title: '山海经异闻录', author: '佚名', cover_url: url })
      expect(cover.kind).toBe('builtin')
    },
  )

  it('maps the six demo titles to builtin covers', () => {
    const titles = Object.keys(COVER_REGISTRY)
    for (const title of titles) {
      const cover = resolveCover({ title, author: '作者' })
      expect(cover.kind).toBe('builtin')
      expect(cover.src).toBe(COVER_REGISTRY[title])
    }
  })

  it('normalizes whitespace and full-width spaces before lookup', () => {
    expect(resolveCover({ title: '  山海经异闻录 ', author: '佚名' }).kind).toBe('builtin')
  })

  it('uses a deterministic placeholder for unknown titles', () => {
    const first = resolveCover({ title: '未知书名', author: '未知作者' })
    const second = resolveCover({ title: '未知书名', author: '未知作者' })
    expect(first.kind).toBe('placeholder')
    expect(first.paletteIndex).toBe(second.paletteIndex)
    expect(first.alt).toContain('未知书名')
    expect(first.alt).toContain('未知作者')
  })

  it('exposes a 12-entry placeholder palette', () => {
    expect(PLACEHOLDER_PALETTE).toHaveLength(12)
    const cover = resolveCover({ title: '未知', author: '' })
    expect(paletteFor(cover)).toBe(PLACEHOLDER_PALETTE[cover.paletteIndex])
  })
})

describe('normalizeTitle', () => {
  it('trims and collapses whitespace', () => {
    expect(normalizeTitle('  山海  经  ')).toBe('山海 经')
  })
})