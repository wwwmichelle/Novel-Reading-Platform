<template>
  <article
    class="book-card"
    role="link"
    tabindex="0"
    @click="open"
    @keydown.enter.prevent="open"
    @keydown.space.prevent="open"
  >
    <div class="cover">
      <CoverImage :book="coverBook" :priority="priority" />
      <span v-if="book.is_demo" class="demo-tag">演示</span>
    </div>
    <div class="info">
      <h3 class="title" :title="book.title">{{ book.title }}</h3>
      <p class="author">{{ book.author }}</p>
      <div class="meta">
        <span class="status" :class="book.serial_status">
          {{ book.serial_status === 'ongoing' ? '连载' : '完结' }}
        </span>
        <span v-if="book.latest_chapter_title" class="latest" :title="book.latest_chapter_title">
          {{ book.latest_chapter_title }}
        </span>
      </div>
    </div>
  </article>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRouter } from 'vue-router'

import type { BookSummary } from '@/types/api'
import CoverImage from '@/components/CoverImage.vue'

const props = withDefaults(defineProps<{ book: BookSummary; priority?: boolean }>(), {
  priority: false,
})

const router = useRouter()

const coverBook = computed(() => ({
  title: props.book.title,
  author: props.book.author,
  cover_url: props.book.cover_url,
}))

function open() {
  router.push(`/books/${props.book.id}`)
}
</script>

<style scoped>
.book-card {
  display: flex;
  flex-direction: column;
  height: 100%;
  cursor: pointer;
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
  overflow: hidden;
  box-shadow: var(--shadow-sm);
  transition: transform var(--dur-fast, 0.15s) ease, box-shadow 0.2s ease, border-color 0.2s ease;
}

.book-card:hover {
  transform: translateY(-2px);
  border-color: #cfd9ea;
  box-shadow: var(--shadow-md);
}

.book-card:focus-visible {
  outline: 2px solid var(--color-primary);
  outline-offset: 2px;
}

.book-card:active {
  transform: translateY(-1px);
}

.cover {
  position: relative;
  width: 100%;
  overflow: hidden;
  background: var(--color-surface-2);
}

.demo-tag {
  position: absolute;
  top: 10px;
  left: 10px;
  z-index: 2;
  padding: 2px 8px;
  border-radius: var(--radius-pill);
  background: rgba(232, 163, 61, 0.92);
  color: #fff;
  font-size: var(--font-xs);
  font-weight: 600;
}

.info {
  padding: 12px 14px 14px;
}

.title {
  font-size: var(--font-sm);
  font-weight: 600;
  line-height: 1.4;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  margin-bottom: 2px;
}

.author {
  font-size: var(--font-xs);
  color: var(--color-text-3);
  margin-bottom: 10px;
}

.meta {
  display: flex;
  align-items: center;
  gap: 8px;
}

.status {
  flex-shrink: 0;
  padding: 1px 8px;
  border-radius: var(--radius-pill);
  font-size: var(--font-xs);
}

.status.ongoing {
  background: var(--color-success-soft);
  color: var(--color-success);
}

.status.completed {
  background: var(--color-surface-2);
  color: var(--color-text-2);
}

.latest {
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  color: var(--color-text-3);
  font-size: var(--font-xs);
}
</style>