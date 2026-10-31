<template>
  <div class="reading" :class="readingStore.theme">
    <div class="toolbar">
      <div class="toolbar-inner container">
        <button type="button" class="tool-btn" @click="goBack">返回目录</button>
        <div class="chapter-nav">
          <button type="button" class="tool-btn" :disabled="!chapter?.prev_chapter_id" @click="prevChapter">上一章</button>
          <button type="button" class="tool-btn" :disabled="!chapter?.next_chapter_id" @click="nextChapter">下一章</button>
        </div>
        <div class="reading-tools">
          <button type="button" class="tool-btn round" aria-label="缩小字号" @click="readingStore.setFontSize(readingStore.fontSize - 1)">A-</button>
          <span class="font-size">{{ readingStore.fontSize }}</span>
          <button type="button" class="tool-btn round" aria-label="放大字号" @click="readingStore.setFontSize(readingStore.fontSize + 1)">A+</button>
          <button type="button" class="tool-btn" @click="readingStore.toggleTheme()">
            {{ readingStore.theme === 'light' ? '夜间' : '日间' }}
          </button>
        </div>
      </div>
    </div>

    <LoadingState v-if="loading" />
    <ErrorState v-else-if="error" :message="error" @retry="loadChapter" />
    <div v-else-if="chapter" class="content-area">
      <h1>{{ chapter.title }}</h1>
      <p class="chapter-meta">第 {{ chapter.order + 1 }} 章 · {{ chapter.word_count }} 字</p>
      <div class="content" :style="{ fontSize: readingStore.fontSize + 'px' }">{{ chapter.content }}</div>

      <div class="chapter-footer">
        <button type="button" class="btn btn-ghost" :disabled="!chapter.prev_chapter_id" @click="prevChapter">上一章</button>
        <button type="button" class="btn btn-primary" :disabled="!chapter.next_chapter_id" @click="nextChapter">下一章</button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'

import { bookApi } from '@/api/book'
import { readingApi } from '@/api/reading'
import { useAuthStore } from '@/stores/auth'
import { useReadingStore } from '@/stores/reading'
import type { ChapterContent } from '@/types/api'
import LoadingState from '@/components/LoadingState.vue'
import ErrorState from '@/components/ErrorState.vue'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()
const readingStore = useReadingStore()

const chapter = ref<ChapterContent | null>(null)
const loading = ref(true)
const error = ref('')
const bookId = computed(() => route.params.bookId as string)

async function loadChapter() {
  loading.value = true
  error.value = ''
  try {
    const chapterId = route.params.chapterId as string
    chapter.value = (await bookApi.chapter(bookId.value, chapterId)).data
    if (authStore.isLoggedIn) {
      readingApi
        .report(bookId.value, {
          chapter_id: chapterId,
          chapter_order: chapter.value.order,
          scroll_position: 0,
          client_timestamp: new Date().toISOString(),
        })
        .catch(() => {})
    }
  } catch (e: any) {
    error.value = e.response?.data?.message || '加载失败'
  } finally {
    loading.value = false
  }
}

function prevChapter() {
  if (chapter.value?.prev_chapter_id) {
    router.push(`/books/${bookId.value}/read/${chapter.value.prev_chapter_id}`)
  }
}

function nextChapter() {
  if (chapter.value?.next_chapter_id) {
    router.push(`/books/${bookId.value}/read/${chapter.value.next_chapter_id}`)
  }
}

function goBack() {
  router.push(`/books/${bookId.value}/chapters`)
}

onMounted(loadChapter)
watch(() => route.params.chapterId, loadChapter)
</script>

<style scoped src="../styles/reading.css"></style>
