import { createPinia, setActivePinia } from 'pinia'
import { beforeEach, describe, expect, it } from 'vitest'

import { useReadingStore } from '@/stores/reading'

describe('useReadingStore', () => {
  beforeEach(() => {
    localStorage.clear()
    setActivePinia(createPinia())
  })

  it('uses default font size and light theme', () => {
    const store = useReadingStore()
    expect(store.fontSize).toBe(18)
    expect(store.theme).toBe('light')
  })

  it('persists font size changes', () => {
    const store = useReadingStore()
    store.setFontSize(22)

    expect(store.fontSize).toBe(22)
    expect(localStorage.getItem('font_size')).toBe('22')
  })

  it('toggles the theme and persists it', () => {
    const store = useReadingStore()

    store.toggleTheme()
    expect(store.theme).toBe('dark')
    expect(localStorage.getItem('theme')).toBe('dark')

    store.toggleTheme()
    expect(store.theme).toBe('light')
    expect(localStorage.getItem('theme')).toBe('light')
  })

  it('restores font size and theme from localStorage', () => {
    localStorage.setItem('font_size', '24')
    localStorage.setItem('theme', 'dark')
    setActivePinia(createPinia())

    const store = useReadingStore()
    expect(store.fontSize).toBe(24)
    expect(store.theme).toBe('dark')
  })
})