<template>
  <PageContainer>
    <SearchBar
      ref="searchBarRef"
      :initial-keyword="keyword"
      :loading="phase === 'loading'"
      @submit="handleSubmit"
      @clear="handleClear"
    />

    <SectionHeader :mode="mode" :keyword="keyword" :total="total" />

    <SkeletonGrid v-if="phase === 'loading'" :count="8" />
    <ErrorState v-else-if="phase === 'error'" :message="errorMessage" @retry="load" />
    <template v-else>
      <div v-if="books.length" class="book-grid">
        <BookCard
          v-for="(book, index) in books"
          :key="book.id"
          :book="book"
          :priority="index < 5"
        />
      </div>
      <EmptyState v-else>
        <template v-if="mode === 'search'">
          <p>未找到与「{{ keyword }}」相关的图书</p>
          <button type="button" class="btn btn-soft" @click="handleClear">清空搜索</button>
        </template>
        <template v-else>
          <p>暂无图书</p>
          <button type="button" class="btn btn-soft" @click="load">刷新</button>
        </template>
      </EmptyState>
      <Pagination :page="page" :total-pages="totalPages" @change="changePage" />
    </template>
  </PageContainer>
</template>

<script setup lang="ts">
import { computed, nextTick, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'

import { bookApi } from '@/api/book'
import { searchApi } from '@/api/search'
import { toAppError, isCanceled } from '@/utils/errors'
import type { BookSummary, SearchScope } from '@/types/api'
import BookCard from '@/components/BookCard.vue'
import EmptyState from '@/components/EmptyState.vue'
import ErrorState from '@/components/ErrorState.vue'
import PageContainer from '@/components/PageContainer.vue'
import Pagination from '@/components/Pagination.vue'
import SearchBar from '@/components/SearchBar.vue'
import SectionHeader from '@/components/SectionHeader.vue'
import SkeletonGrid from '@/components/SkeletonGrid.vue'

const route = useRoute()
const router = useRouter()
const searchBarRef = ref<InstanceType<typeof SearchBar> | null>(null)

const books = ref<BookSummary[]>([])
const total = ref(0)
const totalPages = ref(0)
const phase = ref<'idle' | 'loading' | 'success' | 'empty' | 'error'>('idle')
const errorMessage = ref('')

let requestSeq = 0
let controller: AbortController | null = null

function normalizeKeyword(value: unknown): string {
  return typeof value === 'string' ? value.trim().slice(0, 50) : ''
}

function normalizeScope(value: unknown): SearchScope {
  return value === 'title' || value === 'author' || value === 'both' ? value : 'both'
}

function normalizePage(value: unknown): number {
  const page = Number(value)
  return Number.isInteger(page) && page > 0 ? page : 1
}

const keyword = computed(() => normalizeKeyword(route.query.keyword))
const scope = computed(() => normalizeScope(route.query.scope))
const page = computed(() => normalizePage(route.query.page))
const mode = computed<'browse' | 'search'>(() => (keyword.value ? 'search' : 'browse'))

async function load() {
  const seq = (requestSeq += 1)
  controller?.abort()
  controller = new AbortController()
  phase.value = 'loading'
  errorMessage.value = ''
  try {
    const resp =
      mode.value === 'search'
        ? await searchApi.search(keyword.value, scope.value, page.value, 20, controller.signal)
        : await bookApi.list(page.value, 20, controller.signal)
    if (seq !== requestSeq) return
    books.value = resp.data.items
    total.value = resp.data.total
    totalPages.value = resp.data.total_pages
    phase.value = books.value.length ? 'success' : 'empty'
  } catch (error) {
    if (seq !== requestSeq || isCanceled(error)) return
    errorMessage.value = toAppError(error).message
    phase.value = 'error'
    books.value = []
  }
}

function handleSubmit(nextKeyword: string, nextScope: SearchScope) {
  router.replace({
    path: '/',
    query: { keyword: nextKeyword, scope: nextScope, page: '1' },
  })
}

function handleClear() {
  searchBarRef.value?.setKeyword('')
  router.replace({ path: '/', query: {} })
}

async function changePage(next: number) {
  await router.replace({ path: '/', query: { ...route.query, page: String(next) } })
  await nextTick()
  document.getElementById('search-result-anchor')?.scrollIntoView({ behavior: 'smooth', block: 'start' })
}

watch(
  () => [route.query.keyword, route.query.scope, route.query.page],
  () => {
    searchBarRef.value?.setKeyword(keyword.value)
    load()
  },
  { immediate: true },
)
</script>

<style scoped>
.book-grid {
  display: grid;
  grid-template-columns: repeat(5, minmax(0, 1fr));
  gap: var(--space-3);
}

@media (max-width: 1279px) {
  .book-grid {
    grid-template-columns: repeat(4, minmax(0, 1fr));
  }
}

@media (max-width: 1023px) {
  .book-grid {
    grid-template-columns: repeat(3, minmax(0, 1fr));
  }
}

@media (max-width: 767px) {
  .book-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 12px;
  }
}
</style>