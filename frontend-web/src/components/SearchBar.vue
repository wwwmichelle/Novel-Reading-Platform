<template>
  <form class="search-bar card" role="search" @submit.prevent="handleSubmit">
    <span class="search-icon" aria-hidden="true"></span>
    <input
      v-model="keyword"
      class="search-input"
      type="search"
      maxlength="50"
      placeholder="搜索书名或作者，按回车开始"
      aria-label="搜索书名或作者"
      @input="handleInput"
    />
    <select v-model="scope" class="search-scope" aria-label="搜索范围">
      <option value="both">全部</option>
      <option value="title">书名</option>
      <option value="author">作者</option>
    </select>
    <button v-if="keyword" type="button" class="search-clear" @click="handleClear">清空</button>
    <button type="submit" class="btn btn-primary search-submit" :disabled="loading">搜索</button>
  </form>
  <p v-if="error" class="search-error" role="alert">{{ error }}</p>
</template>

<script setup lang="ts">
import { ref } from 'vue'

import type { SearchScope } from '@/types/api'

const props = withDefaults(defineProps<{ initialKeyword?: string; loading?: boolean }>(), {
  initialKeyword: '',
  loading: false,
})

const emit = defineEmits<{
  submit: [keyword: string, scope: SearchScope]
  clear: []
}>()

const keyword = ref(props.initialKeyword)
const scope = ref<SearchScope>('both')
const error = ref('')

function normalize(value: string): string {
  return value.trim().slice(0, 50)
}

function handleSubmit() {
  const value = normalize(keyword.value)
  if (!value) {
    error.value = '请输入搜索关键词'
    return
  }
  error.value = ''
  emit('submit', value, scope.value)
}

function handleClear() {
  keyword.value = ''
  error.value = ''
  emit('clear')
}

function handleInput() {
  if (!keyword.value.trim()) {
    error.value = ''
    emit('clear')
  }
}

defineExpose({ setKeyword: (value: string) => { keyword.value = value }, clearError: () => { error.value = '' } })
</script>

<style scoped>
.search-bar {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 12px 10px 16px;
  margin-bottom: var(--space-3);
  border-radius: var(--radius-pill);
}

.search-icon {
  width: 14px;
  height: 14px;
  border: 2px solid var(--color-text-3);
  border-radius: 50%;
  position: relative;
  flex-shrink: 0;
}

.search-icon::after {
  content: '';
  position: absolute;
  right: -5px;
  bottom: -4px;
  width: 7px;
  height: 2px;
  background: var(--color-text-3);
  transform: rotate(45deg);
  border-radius: 2px;
}

.search-input {
  flex: 1;
  min-width: 0;
  border: none;
  outline: none;
  background: transparent;
  font-size: var(--font-md);
  color: var(--color-text);
  min-height: 36px;
}

.search-input::placeholder {
  color: var(--color-text-3);
}

.search-scope {
  border: 1px solid var(--color-border);
  border-radius: var(--radius-pill);
  background: var(--color-surface);
  color: var(--color-text-2);
  font-size: var(--font-xs);
  min-height: 34px;
  padding: 0 10px;
}

.search-clear {
  border: none;
  background: transparent;
  color: var(--color-text-3);
  font-size: var(--font-sm);
  padding: 4px 6px;
}

.search-clear:hover {
  color: var(--color-danger);
}

.search-submit {
  flex-shrink: 0;
  border-radius: var(--radius-pill);
  padding: 0 22px;
}

.search-error {
  margin: -8px 0 var(--space-3) 16px;
  color: var(--color-danger);
  font-size: var(--font-xs);
}

@media (max-width: 768px) {
  .search-bar {
    padding: 8px 10px 8px 12px;
    flex-wrap: wrap;
  }

  .search-input {
    font-size: var(--font-sm);
  }

  .search-scope {
    display: none;
  }

  .search-submit {
    padding: 0 16px;
  }
}
</style>