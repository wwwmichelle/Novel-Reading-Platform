<template>
  <div class="book-detail page">
    <div class="container narrow">
      <template v-if="book">
        <router-link to="/" class="back">← 返回书目</router-link>

        <section class="header card">
          <div class="detail-cover">
            <CoverImage :book="coverBook" :priority="true" />
          </div>
          <div class="info">
            <h1>{{ book.title }}</h1>
            <p class="author">作者：{{ book.author }}</p>
            <p class="status">{{ book.serial_status === 'ongoing' ? '连载中' : '已完结' }}</p>
            <div class="cats">
              <span v-for="cat in book.categories" :key="cat" class="cat-tag">{{ cat }}</span>
              <span v-if="book.is_demo" class="demo-tag">演示数据</span>
            </div>
            <div class="actions">
              <a v-if="sourceUrl" class="btn btn-primary" :href="sourceUrl" target="_blank" rel="noopener noreferrer">前往源网站阅读 ↗</a>
              <button v-else type="button" class="btn btn-primary" @click="goRead">开始阅读</button>
              <button v-if="!sourceUrl" type="button" class="btn btn-soft" @click="viewChapters">查看目录</button>
              <button type="button" class="btn btn-ghost" :disabled="shelfLoading" @click="toggleBookshelf">
                {{ inShelf ? '移出书架' : '加入书架' }}
              </button>
            </div>
          </div>
        </section>

        <section class="desc card">
          <h3>简介</h3>
          <p>{{ book.description || '暂无简介' }}</p>
        </section>

        <section class="comments card">
          <h3>评论 <span class="comment-count">{{ commentTotal }}</span></h3>
          <form v-if="authStore.isLoggedIn" @submit.prevent="submitComment" class="comment-form">
            <textarea
              v-model="commentContent"
              placeholder="写下你的评论..."
              maxlength="1000"
              rows="3"
            ></textarea>
            <div class="comment-actions">
              <span class="counter">{{ commentContent.length }}/1000</span>
              <button type="submit" class="btn btn-primary" :disabled="!commentContent.trim() || submitting">
                {{ submitting ? '发表中...' : '发表评论' }}
              </button>
            </div>
          </form>
          <router-link v-else class="btn btn-soft" :to="{ name: 'login', query: { redirect: route.fullPath } }">登录后发表评论</router-link>
          <div class="comment-list">
            <div v-for="c in comments" :key="c.id" class="comment-item">
              <div class="comment-head">
                <span class="avatar">{{ c.username.charAt(0) }}</span>
                <span class="username">{{ c.username }}</span>
                <span class="time">{{ formatTime(c.created_at) }}</span>
                <button
                  v-if="authStore.user?.id === c.user_id || authStore.isAdmin"
                  class="del remove-btn"
                  type="button"
                  @click="deleteComment(c)"
                >
                  删除
                </button>
              </div>
              <p class="content">{{ c.content }}</p>
            </div>
            <p v-if="!comments.length" class="no-comments">还没有评论，来写下第一条吧</p>
          </div>
          <Pagination v-if="commentTotalPages > 1" :page="commentPage" :total-pages="commentTotalPages" @change="loadComments" />
        </section>
      </template>
      <LoadingState v-else-if="loading" />
      <ErrorState v-else :message="error" @retry="loadBook" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'

import { isSafeSourceUrl } from '@/utils/url'
import { bookApi } from '@/api/book'
import { readingApi } from '@/api/reading'
import { commentApi } from '@/api/comment'
import { useAuthStore } from '@/stores/auth'
import { useBookshelfStore } from '@/stores/bookshelf'
import { useToast } from '@/composables/useToast'
import { useConfirm } from '@/composables/useConfirm'
import type { BookDetail, CommentResponse } from '@/types/api'
import CoverImage from '@/components/CoverImage.vue'
import LoadingState from '@/components/LoadingState.vue'
import ErrorState from '@/components/ErrorState.vue'
import Pagination from '@/components/Pagination.vue'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()
const shelfStore = useBookshelfStore()
const toast = useToast()
const confirm = useConfirm()

const book = ref<BookDetail | null>(null)
const loading = ref(true)
const error = ref('')
const comments = ref<CommentResponse[]>([])
const commentTotal = ref(0)
const commentPage = ref(1)
const commentTotalPages = ref(0)
const commentContent = ref('')
const submitting = ref(false)
const shelfLoading = ref(false)

const bookId = computed(() => route.params.bookId as string)
const coverBook = computed(() => ({
  title: book.value?.title ?? '',
  author: book.value?.author ?? '',
  cover_url: book.value?.cover_url ?? null,
}))
const sourceUrl = computed(() => {
  const url = book.value?.source_url ?? ''
  return isSafeSourceUrl(url) ? url : null
})
const inShelf = computed(() => shelfStore.isInBookshelf(bookId.value))

function formatTime(value: string) {
  return new Date(value).toLocaleString('zh-CN')
}

async function loadBook() {
  loading.value = true
  error.value = ''
  try {
    book.value = (await bookApi.detail(bookId.value)).data
  } catch (e: any) {
    error.value = e.response?.data?.message || '加载失败'
  } finally {
    loading.value = false
  }
}

async function loadComments(target = 1) {
  commentPage.value = target
  try {
    const resp = await commentApi.list(bookId.value, target)
    comments.value = resp.data.items
    commentTotal.value = resp.data.total
    commentTotalPages.value = resp.data.total_pages
  } catch {
    comments.value = []
    commentTotal.value = 0
    commentTotalPages.value = 0
  }
}

async function submitComment() {
  submitting.value = true
  try {
    await commentApi.create(bookId.value, commentContent.value)
    commentContent.value = ''
    toast.success('评论已发表')
    await loadComments()
  } catch (e: any) {
    toast.error(e.response?.data?.message || '发表失败')
  } finally {
    submitting.value = false
  }
}

async function deleteComment(comment: CommentResponse) {
  const confirmed = await confirm.ask({
    title: '删除评论',
    message: '确定删除这条评论？',
    confirmText: '删除',
    danger: true,
  })
  if (!confirmed) return
  try {
    await commentApi.delete(comment.id)
    toast.success('评论已删除')
    await loadComments(commentPage.value)
  } catch (e: any) {
    toast.error(e.response?.data?.message || '删除失败')
  }
}

async function toggleBookshelf() {
  if (!authStore.isLoggedIn) {
    router.push({ name: 'login', query: { redirect: route.fullPath } })
    return
  }
  shelfLoading.value = true
  try {
    if (inShelf.value) {
      await shelfStore.remove(bookId.value)
      toast.success('已移出书架')
    } else {
      await shelfStore.add(bookId.value)
      toast.success('已加入书架')
    }
  } catch (e: any) {
    toast.error(e.response?.data?.message || '操作失败')
  } finally {
    shelfLoading.value = false
  }
}

async function goRead() {
  try {
    if (authStore.isLoggedIn) {
      try {
        const progress = (await readingApi.get(bookId.value)).data
        if (progress.chapter_id) {
          await router.push(`/books/${bookId.value}/read/${progress.chapter_id}`)
          return
        }
      } catch (error: any) {
        if (error.response?.status !== 404) throw error
      }
    }
    const chapters = (await bookApi.chapters(bookId.value)).data
    if (!chapters.length) { toast.error('暂无可阅读章节'); return }
    await router.push(`/books/${bookId.value}/read/${chapters[0].id}`)
  } catch (error: any) {
    toast.error(error.response?.data?.message || '无法打开阅读，请重试')
  }
}

function viewChapters() {
  router.push(`/books/${bookId.value}/chapters`)
}

onMounted(async () => {
  await loadBook()
  await loadComments()
  if (authStore.isLoggedIn) {
    shelfStore.fetch().catch(() => undefined)
  }
})
</script>

<style scoped src="../styles/book-detail.css"></style>
