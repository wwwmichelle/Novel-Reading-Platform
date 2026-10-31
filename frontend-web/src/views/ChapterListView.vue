<template>
  <div class="chapter-list page">
    <div class="container narrow">
      <div class="heading">
        <router-link :to="`/books/${bookId}`" class="back">← 返回详情</router-link>
        <h2 class="section-title">{{ bookTitle || '章节目录' }}</h2>
        <p class="subtitle" v-if="chapters.length">共 {{ chapters.length }} 章</p>
      </div>

      <LoadingState v-if="loading" />
      <ErrorState v-else-if="error" :message="error" @retry="load" />
      <div v-else class="chapters card">
        <div
          v-for="ch in chapters"
          :key="ch.id"
          class="chapter-item"
          @click="$router.push(`/books/${bookId}/read/${ch.id}`)"
        >
          <span class="order">第{{ ch.order + 1 }}章</span>
          <span class="title">{{ ch.title }}</span>
          <span class="words">{{ ch.word_count }}字</span>
        </div>
        <EmptyState v-if="!chapters.length" message="暂无章节" />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useRoute } from 'vue-router'

import { bookApi } from '@/api/book'
import type { ChapterBrief } from '@/types/api'
import LoadingState from '@/components/LoadingState.vue'
import ErrorState from '@/components/ErrorState.vue'
import EmptyState from '@/components/EmptyState.vue'

const route = useRoute()
const bookId = route.params.bookId as string
const bookTitle = ref('')
const chapters = ref<ChapterBrief[]>([])
const loading = ref(true)
const error = ref('')

async function load() {
  loading.value = true
  error.value = ''
  try {
    const [detail, list] = await Promise.all([bookApi.detail(bookId), bookApi.chapters(bookId)])
    bookTitle.value = detail.data.title
    chapters.value = list.data
  } catch (e: any) {
    error.value = e.response?.data?.message || '加载失败'
  } finally {
    loading.value = false
  }
}

onMounted(load)
</script>

<style scoped>
.narrow {
  max-width: 820px;
}

.heading {
  margin-bottom: var(--space-3);
}

.back {
  display: inline-block;
  margin-bottom: 8px;
  color: var(--color-text-3);
  font-size: var(--font-sm);
}

.back:hover {
  color: var(--color-primary);
}

.heading .section-title {
  margin-bottom: 3px;
}

.subtitle {
  color: var(--color-text-3);
  font-size: var(--font-xs);
}

.chapters {
  border-radius: var(--radius-md);
  overflow: hidden;
}

.chapter-item {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 15px 20px;
  border-bottom: 1px solid var(--color-border);
  cursor: pointer;
  transition: background-color 0.16s ease, color 0.16s ease;
}

.chapter-item:last-child {
  border-bottom: none;
}

.chapter-item:hover {
  background: var(--color-primary-soft);
}

.order {
  min-width: 66px;
  color: var(--color-text-3);
  font-size: var(--font-xs);
}

.chapter-item:hover .order {
  color: var(--color-primary);
}

.title {
  flex: 1;
  font-size: var(--font-sm);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.words {
  color: var(--color-text-3);
  font-size: var(--font-xs);
}
</style>