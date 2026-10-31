<template>
  <div class="category-books page">
    <div class="container">
      <div class="heading">
        <router-link to="/categories" class="back">← 返回分类</router-link>
        <h2 class="section-title">{{ categoryName || '分类书目' }}</h2>
      </div>

      <LoadingState v-if="loading" message="正在加载书目..." />
      <ErrorState v-else-if="error" :message="error" @retry="loadBooks()" />
      <template v-else>
        <div v-if="books.length" class="book-grid">
          <BookCard v-for="book in books" :key="book.id" :book="book" />
        </div>
        <EmptyState v-else message="该分类下暂无图书" />
        <Pagination :page="page" :total-pages="totalPages" @change="loadBooks" />
      </template>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref, watch } from 'vue'
import { useRoute } from 'vue-router'

import { categoryApi } from '@/api/category'
import type { BookSummary } from '@/types/api'
import BookCard from '@/components/BookCard.vue'
import LoadingState from '@/components/LoadingState.vue'
import EmptyState from '@/components/EmptyState.vue'
import ErrorState from '@/components/ErrorState.vue'
import Pagination from '@/components/Pagination.vue'

const route = useRoute()
const books = ref<BookSummary[]>([])
const page = ref(1)
const totalPages = ref(0)
const loading = ref(true)
const error = ref('')
const categoryName = ref('')

async function loadCategoryName() {
  try {
    const categories = (await categoryApi.list()).data
    const match = categories.find((item) => item.id === route.params.categoryId)
    categoryName.value = match?.name || '分类书目'
  } catch {
    categoryName.value = '分类书目'
  }
}

async function loadBooks(target = 1) {
  loading.value = true
  error.value = ''
  page.value = target
  try {
    const resp = await categoryApi.books(route.params.categoryId as string, target)
    books.value = resp.data.items
    totalPages.value = resp.data.total_pages
  } catch (e: any) {
    error.value = e.response?.data?.message || '加载失败'
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadCategoryName()
  loadBooks()
})

watch(
  () => route.params.categoryId,
  () => {
    loadCategoryName()
    loadBooks()
  },
)
</script>

<style scoped>
.heading {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-bottom: var(--space-4);
}

.back {
  color: var(--color-text-3);
  font-size: var(--font-sm);
  width: fit-content;
  transition: color 0.18s ease;
}

.back:hover {
  color: var(--color-primary);
}

.heading .section-title {
  margin-bottom: 0;
}

.book-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
  gap: var(--space-3);
}

@media (max-width: 768px) {
  .book-grid {
    grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
    gap: 12px;
  }
}
</style>