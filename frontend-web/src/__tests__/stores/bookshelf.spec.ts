import { createPinia, setActivePinia } from 'pinia'
import { beforeEach, describe, expect, it, vi } from 'vitest'

vi.mock('@/api/bookshelf', () => ({
  bookshelfApi: {
    list: vi.fn(),
    add: vi.fn(),
    remove: vi.fn(),
  },
}))

import { bookshelfApi } from '@/api/bookshelf'
import { useBookshelfStore } from '@/stores/bookshelf'
import type { BookshelfItem } from '@/types/api'

const mockedApi = vi.mocked(bookshelfApi)

function item(overrides: Partial<BookshelfItem> = {}): BookshelfItem {
  return {
    id: 'shelf-1',
    book_id: 'book-1',
    book_title: '山海经异闻录',
    book_author: '佚名',
    cover_url: null,
    last_read_chapter_id: null,
    last_read_chapter_title: null,
    last_read_time: null,
    added_at: '2026-10-29T13:18:26.486541Z',
    ...overrides,
  }
}

function response<T>(data: T) {
  return { data } as never
}

describe('useBookshelfStore', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
    vi.clearAllMocks()
  })

  it('loads items and toggles the loading flag', async () => {
    mockedApi.list.mockResolvedValue(response([item()]))
    const store = useBookshelfStore()

    const pending = store.fetch()
    expect(store.loading).toBe(true)
    await pending

    expect(store.items).toHaveLength(1)
    expect(store.loading).toBe(false)
    expect(store.error).toBe('')
  })

  it('keeps existing items and records an error when refresh fails', async () => {
    mockedApi.list.mockResolvedValueOnce(response([item()]))
    const store = useBookshelfStore()
    await store.fetch()
    expect(store.items).toHaveLength(1)

    mockedApi.list.mockRejectedValueOnce({ response: { status: 500 } })
    await expect(store.fetch()).rejects.toBeTruthy()

    expect(store.items).toHaveLength(1)
    expect(store.error).not.toBe('')
    expect(store.loading).toBe(false)
  })

  it('adds a book and refreshes the shelf', async () => {
    mockedApi.add.mockResolvedValue(response({}))
    mockedApi.list.mockResolvedValue(response([item()]))
    const store = useBookshelfStore()

    await store.add('book-1')

    expect(mockedApi.add).toHaveBeenCalledWith('book-1')
    expect(store.items).toHaveLength(1)
  })

  it('removes a book from the local list', async () => {
    mockedApi.list.mockResolvedValue(response([item()]))
    mockedApi.remove.mockResolvedValue(response({}))
    const store = useBookshelfStore()

    await store.fetch()
    await store.remove('book-1')

    expect(mockedApi.remove).toHaveBeenCalledWith('book-1')
    expect(store.items).toHaveLength(0)
  })

  it('reports membership correctly', async () => {
    mockedApi.list.mockResolvedValue(response([item()]))
    const store = useBookshelfStore()
    await store.fetch()

    expect(store.isInBookshelf('book-1')).toBe(true)
    expect(store.isInBookshelf('book-2')).toBe(false)
  })

  it('sorts read books first by last read time, then unread by added time', async () => {
    mockedApi.list.mockResolvedValue(
      response([
        item({ id: 'unread-old', book_id: 'b-old', added_at: '2026-01-01T00:00:00Z' }),
        item({ id: 'read', book_id: 'b-read', last_read_time: '2026-03-01T00:00:00Z', last_read_chapter_id: 'c1' }),
        item({ id: 'unread-new', book_id: 'b-new', added_at: '2026-02-01T00:00:00Z' }),
      ]),
    )
    const store = useBookshelfStore()
    await store.fetch()

    expect(store.sortedItems.map((entry) => entry.id)).toEqual(['read', 'unread-new', 'unread-old'])
  })

  it('returns a continue target only when a chapter was read', () => {
    const store = useBookshelfStore()
    expect(store.continueTarget(item({ book_id: 'b1', last_read_chapter_id: 'c1' }))).toBe('/books/b1/read/c1')
    expect(store.continueTarget(item({ book_id: 'b1', last_read_chapter_id: null }))).toBeNull()
  })

  it('does not drop items when remove fails', async () => {
    mockedApi.list.mockResolvedValue(response([item()]))
    const store = useBookshelfStore()
    await store.fetch()

    mockedApi.remove.mockRejectedValue(new Error('boom'))
    await expect(store.remove('book-1')).rejects.toThrow('boom')
    expect(store.items).toHaveLength(1)
  })
})