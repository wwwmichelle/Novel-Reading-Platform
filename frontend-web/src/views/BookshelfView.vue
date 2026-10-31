<template>
  <PageContainer>
    <div class="shelf-head">
      <h2 class="section-title">我的书架</h2>
      <span class="count">{{ shelfStore.items.length }} 本</span>
    </div>

    <LoadingState v-if="shelfStore.loading && !shelfStore.items.length" />
    <ErrorState
      v-else-if="shelfStore.error && !shelfStore.items.length"
      :message="shelfStore.error"
      @retry="reload"
    />
    <EmptyState v-else-if="!shelfStore.items.length" message="书架还是空的">
      <p>书架还是空的，去挑一本喜欢的书吧</p>
      <router-link class="btn btn-soft" to="/">去浏览书目</router-link>
    </EmptyState>
    <div v-else class="list">
      <article v-for="item in shelfStore.sortedItems" :key="item.id" class="shelf-item card">
        <div class="shelf-cover" @click="openBook(item.book_id)">
          <CoverImage
            :book="{ title: item.book_title, author: item.book_author, cover_url: item.cover_url }"
          />
        </div>
        <div class="info" @click="openBook(item.book_id)">
          <h3>{{ item.book_title }}</h3>
          <p class="author">{{ item.book_author }}</p>
          <p v-if="item.last_read_chapter_title" class="last-read">
            最近阅读：{{ item.last_read_chapter_title }}
          </p>
          <p v-else class="last-read muted">尚未开始阅读</p>
        </div>
        <div class="actions">
          <button
            v-if="shelfStore.continueTarget(item)"
            type="button"
            class="btn btn-soft continue-btn"
            @click="continueReading(item)"
          >
            继续阅读
          </button>
          <button type="button" class="btn btn-danger remove-btn" @click="remove(item)">移出</button>
        </div>
      </article>
    </div>
  </PageContainer>
</template>

<script setup lang="ts">
import { onMounted } from 'vue'
import { useRouter } from 'vue-router'

import { useBookshelfStore } from '@/stores/bookshelf'
import { useToast } from '@/composables/useToast'
import { useConfirm } from '@/composables/useConfirm'
import type { BookshelfItem } from '@/types/api'
import CoverImage from '@/components/CoverImage.vue'
import EmptyState from '@/components/EmptyState.vue'
import ErrorState from '@/components/ErrorState.vue'
import LoadingState from '@/components/LoadingState.vue'
import PageContainer from '@/components/PageContainer.vue'

const shelfStore = useBookshelfStore()
const router = useRouter()
const toast = useToast()
const confirm = useConfirm()

function openBook(bookId: string) {
  router.push(`/books/${bookId}`)
}

function continueReading(item: BookshelfItem) {
  const target = shelfStore.continueTarget(item)
  if (target) router.push(target)
}

function reload() {
  shelfStore.fetch().catch(() => undefined)
}

async function remove(item: BookshelfItem) {
  const confirmed = await confirm.ask({
    title: '移出书架',
    message: `确定将《${item.book_title}》移出书架？`,
    confirmText: '移出',
    danger: true,
  })
  if (!confirmed) return
  try {
    await shelfStore.remove(item.book_id)
    toast.success('已移出书架')
  } catch (e: any) {
    toast.error(e?.response?.data?.message || '移出失败，请重试')
    reload()
  }
}

onMounted(() => {
  shelfStore.fetch().catch(() => undefined)
})
</script>

<style scoped>
.shelf-head {
  display: flex;
  align-items: baseline;
  gap: 12px;
  margin-bottom: var(--space-3);
}

.shelf-head .section-title {
  margin-bottom: 0;
}

.count {
  color: var(--color-text-3);
  font-size: var(--font-sm);
}

.list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.shelf-item {
  display: flex;
  align-items: center;
  gap: 18px;
  padding: 14px 18px;
  border-radius: var(--radius-md);
  transition: box-shadow 0.18s ease, border-color 0.18s ease;
}

.shelf-item:hover {
  border-color: #cfd9ea;
  box-shadow: var(--shadow-md);
}

.shelf-cover {
  width: 53px;
  flex-shrink: 0;
  cursor: pointer;
}

.info {
  flex: 1;
  min-width: 0;
  cursor: pointer;
}

.info h3 {
  font-size: var(--font-md);
  margin-bottom: 4px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.author {
  font-size: var(--font-xs);
  color: var(--color-text-3);
  margin-bottom: 4px;
}

.last-read {
  font-size: var(--font-xs);
  color: var(--color-primary);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.last-read.muted {
  color: var(--color-text-3);
}

.actions {
  display: flex;
  gap: 8px;
  flex-shrink: 0;
}

@media (max-width: 640px) {
  .shelf-item {
    flex-wrap: wrap;
  }

  .actions {
    width: 100%;
    justify-content: flex-end;
  }
}
</style>