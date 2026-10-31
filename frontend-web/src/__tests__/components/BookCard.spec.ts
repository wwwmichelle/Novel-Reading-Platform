import { mount } from '@vue/test-utils'
import { beforeEach, describe, expect, it, vi } from 'vitest'

const mocks = vi.hoisted(() => ({ push: vi.fn() }))

vi.mock('vue-router', () => ({
  useRouter: () => ({ push: mocks.push }),
}))

import BookCard from '@/components/BookCard.vue'
import type { BookSummary } from '@/types/api'

const baseBook: BookSummary = {
  id: 'book-1',
  title: '山海经异闻录',
  author: '佚名',
  cover_url: null,
  serial_status: 'completed',
  latest_chapter_title: '第四章 鲲鹏南徙',
  is_demo: true,
  updated_at: '2026-10-29T13:18:26.486541Z',
}

function mountCard(book: BookSummary) {
  return mount(BookCard, { props: { book } })
}

describe('BookCard', () => {
  beforeEach(() => vi.clearAllMocks())

  it('renders title and author', () => {
    const wrapper = mountCard(baseBook)
    expect(wrapper.text()).toContain('山海经异闻录')
    expect(wrapper.text()).toContain('佚名')
  })

  it('shows the demo tag for demo books', () => {
    expect(mountCard(baseBook).find('.demo-tag').exists()).toBe(true)
  })

  it('hides the demo tag for non-demo books', () => {
    expect(mountCard({ ...baseBook, is_demo: false }).find('.demo-tag').exists()).toBe(false)
  })

  it('shows completed status text', () => {
    expect(mountCard(baseBook).find('.status').text()).toBe('完结')
  })

  it('shows ongoing status text', () => {
    expect(mountCard({ ...baseBook, serial_status: 'ongoing' }).find('.status').text()).toBe('连载')
  })

  it('renders a deterministic placeholder containing the title', () => {
    const wrapper = mountCard(baseBook)
    expect(wrapper.find('.cover__placeholder').text()).toContain('山海经异闻录')
  })

  it('renders the builtin cover image', () => {
    const wrapper = mountCard(baseBook)
    expect(wrapper.find('.cover__img').attributes('src')).toBe('/covers/demo-001.svg')
  })

  it('falls back to the placeholder when the cover fails', async () => {
    const wrapper = mountCard(baseBook)
    await wrapper.find('.cover__img').trigger('error')
    expect(wrapper.find('.cover__img').exists()).toBe(false)
    expect(wrapper.find('.cover__placeholder').exists()).toBe(true)
  })

  it('navigates to the detail page when clicked', async () => {
    const wrapper = mountCard(baseBook)
    await wrapper.trigger('click')
    expect(mocks.push).toHaveBeenCalledWith('/books/book-1')
  })

  it('is keyboard focusable and enter triggers navigation', async () => {
    const wrapper = mountCard(baseBook)
    expect(wrapper.attributes('tabindex')).toBe('0')
    await wrapper.trigger('keydown', { key: 'Enter' })
    expect(mocks.push).toHaveBeenCalledWith('/books/book-1')
  })
})