import { describe, expect, it } from 'vitest'

import { fnv1a } from '@/utils/hash'

const titles = [
  '山海经异闻录',
  '桃花源新记',
  '星河漫游者',
  '江湖夜雨十年灯',
  '雾中迷案',
  '月下花前集',
]

describe('fnv1a', () => {
  it('is deterministic for the same input', () => {
    expect(fnv1a('山海经异闻录')).toBe(fnv1a('山海经异闻录'))
  })

  it('returns an unsigned 32-bit integer', () => {
    for (const title of titles) {
      const value = fnv1a(title)
      expect(value).toBeGreaterThanOrEqual(0)
      expect(value).toBeLessThanOrEqual(0xffffffff)
      expect(Number.isInteger(value)).toBe(true)
    }
  })

  it('produces different hashes for different titles', () => {
    const values = new Set(titles.map((title) => fnv1a(title)))
    expect(values.size).toBe(titles.length)
  })

  it('differs for a single character change', () => {
    expect(fnv1a('山海经异闻录')).not.toBe(fnv1a('山海经异闻录x'))
  })

  it('has a stable empty-string hash', () => {
    expect(fnv1a('')).toBe(0x811c9dc5 >>> 0)
  })
})