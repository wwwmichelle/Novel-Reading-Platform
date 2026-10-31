import { flushPromises, mount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import { beforeEach, describe, expect, it, vi } from 'vitest'

const mocks = vi.hoisted(() => ({
  route: { query: {} as Record<string, string> },
  replace: vi.fn(),
  push: vi.fn(),
}))

vi.mock('vue-router', () => ({
  useRoute: () => mocks.route,
  useRouter: () => ({ replace: mocks.replace, push: mocks.push }),
}))

vi.mock('@/api/book', () => ({ bookApi: { list: vi.fn() } }))
vi.mock('@/api/search', () => ({ searchApi: { search: vi.fn() } }))

import { bookApi } from '@/api/book'
import { searchApi } from '@/api/search'
import HomeView from '@/views/HomeView.vue'
import type { BookSummary } from '@/types/api'

const book: BookSummary = {
  id: 'b1',
  title: '山海经异闻录',
  author: '佚名',
  cover_url: null,
  serial_status: 'completed',
  latest_chapter_title: null,
  is_demo: true,
  updated_at: '2026-01-01T00:00:00Z',
}

function page(items: BookSummary[]) {
  return { data: { items, total: items.length, page: 1, page_size: 20, total_pages: 1 } }
}

describe('HomeView', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
    mocks.route.query = {}
    vi.clearAllMocks()
  })

  it('shows 书目浏览 and no category block in browse mode', async () => {
    vi.mocked(bookApi.list).mockResolvedValue(page([book]) as never)
    const wrapper = mount(HomeView)
    await flushPromises()

    expect(wrapper.find('.section-title').text()).toContain('书目浏览')
    expect(wrapper.findAll('.cat-item')).toHaveLength(0)
    expect(wrapper.findAll('.book-card')).toHaveLength(1)
  })

  it('shows the keyword and total in search mode', async () => {
    mocks.route.query = { keyword: '山海' }
    vi.mocked(searchApi.search).mockResolvedValue(page([book]) as never)
    const wrapper = mount(HomeView)
    await flushPromises()

    const heading = wrapper.find('.section-title').text()
    expect(heading).toContain('搜索结果')
    expect(heading).toContain('山海')
    expect(searchApi.search).toHaveBeenCalledWith('山海', 'both', 1, 20, expect.anything())
  })

  it('renders an empty state with a clear action when there are no results', async () => {
    mocks.route.query = { keyword: '无结果' }
    vi.mocked(searchApi.search).mockResolvedValue(page([]) as never)
    const wrapper = mount(HomeView)
    await flushPromises()

    expect(wrapper.find('.empty-state').text()).toContain('无结果')
    expect(wrapper.find('.empty-state button').exists()).toBe(true)
  })

  it('keeps the keyword visible when the search request fails', async () => {
    mocks.route.query = { keyword: '山海' }
    vi.mocked(searchApi.search).mockRejectedValue({
      response: { status: 500, data: { message: '服务异常' } },
    })
    const wrapper = mount(HomeView)
    await flushPromises()

    expect(wrapper.text()).toContain('服务异常')
    expect(wrapper.text()).toContain('山海')
  })
})