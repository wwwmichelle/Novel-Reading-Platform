<template>
  <div class="category-list page">
    <div class="container">
      <h2 class="section-title">全部分类</h2>
      <LoadingState v-if="loading" />
      <ErrorState v-else-if="error" :message="error" @retry="load" />
      <div v-else class="grid">
        <router-link
          v-for="cat in categories"
          :key="cat.id"
          :to="`/categories/${cat.id}`"
          class="cat-card card"
        >
          <span class="cat-mark">{{ cat.name.charAt(0) }}</span>
          <span class="cat-name">{{ cat.name }}</span>
          <span class="cat-arrow">→</span>
        </router-link>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from 'vue'

import { categoryApi } from '@/api/category'
import type { CategoryBrief } from '@/types/api'
import LoadingState from '@/components/LoadingState.vue'
import ErrorState from '@/components/ErrorState.vue'

const categories = ref<CategoryBrief[]>([])
const loading = ref(true)
const error = ref('')

async function load() {
  loading.value = true
  error.value = ''
  try {
    categories.value = (await categoryApi.list()).data
  } catch (e: any) {
    error.value = e.response?.data?.message || '加载失败'
  } finally {
    loading.value = false
  }
}

onMounted(load)
</script>

<style scoped>
.grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: var(--space-3);
}

.cat-card {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 20px;
  border-radius: var(--radius-md);
  transition: transform 0.18s ease, box-shadow 0.18s ease, border-color 0.18s ease;
}

.cat-card:hover {
  transform: translateY(-3px);
  border-color: var(--color-primary);
  box-shadow: var(--shadow-md);
}

.cat-mark {
  display: grid;
  place-items: center;
  width: 44px;
  height: 44px;
  border-radius: 12px;
  background: var(--color-primary-soft);
  color: var(--color-primary);
  font-size: 18px;
  font-weight: 700;
}

.cat-name {
  flex: 1;
  font-size: var(--font-md);
  font-weight: 600;
  color: var(--color-text);
}

.cat-arrow {
  color: var(--color-text-3);
  transition: color 0.18s ease, transform 0.18s ease;
}

.cat-card:hover .cat-arrow {
  color: var(--color-primary);
  transform: translateX(3px);
}

@media (max-width: 768px) {
  .grid {
    grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
    gap: 12px;
  }

  .cat-card {
    padding: 12px;
    gap: 8px;
  }

  .cat-mark {
    width: 32px;
    height: 32px;
    flex-shrink: 0;
    font-size: 16px;
  }

  .cat-name {
    font-size: var(--font-sm);
    white-space: nowrap;
  }
}
</style>
