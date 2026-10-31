import { computed, ref } from 'vue'
import { defineStore } from 'pinia'

import { bookshelfApi } from '@/api/bookshelf'
import type { BookshelfItem } from '@/types/api'
import { toAppError } from '@/utils/errors'

function timeValue(value: string | null): number {
  if (!value) return 0
  const time = new Date(value).getTime()
  return Number.isNaN(time) ? 0 : time
}

export const useBookshelfStore = defineStore('bookshelf', () => {
  const items = ref<BookshelfItem[]>([])
  const loading = ref(false)
  const error = ref('')
  let revision = 0

  function reset() {
    revision += 1
    items.value = []
    error.value = ''
    loading.value = false
  }

  async function fetch() {
    const currentRevision = revision
    loading.value = true
    error.value = ''
    try {
      const resp = await bookshelfApi.list()
      if (currentRevision === revision) items.value = resp.data
    } catch (e) {
      if (currentRevision === revision) error.value = toAppError(e).message
      throw e
    } finally {
      if (currentRevision === revision) loading.value = false
    }
  }

  async function add(bookId: string) {
    await bookshelfApi.add(bookId)
    await fetch()
  }

  async function remove(bookId: string) {
    await bookshelfApi.remove(bookId)
    items.value = items.value.filter((item) => item.book_id !== bookId)
  }

  function isInBookshelf(bookId: string) {
    return items.value.some((item) => item.book_id === bookId)
  }

  const sortedItems = computed(() => {
    const read = items.value
      .filter((item) => Boolean(item.last_read_time))
      .slice()
      .sort((a, b) => timeValue(b.last_read_time) - timeValue(a.last_read_time))
    const unread = items.value
      .filter((item) => !item.last_read_time)
      .slice()
      .sort((a, b) => timeValue(b.added_at) - timeValue(a.added_at))
    return [...read, ...unread]
  })

  function continueTarget(item: BookshelfItem): string | null {
    if (!item.last_read_chapter_id) return null
    return `/books/${item.book_id}/read/${item.last_read_chapter_id}`
  }

  return { items, loading, error, sortedItems, reset, fetch, add, remove, isInBookshelf, continueTarget }
})
