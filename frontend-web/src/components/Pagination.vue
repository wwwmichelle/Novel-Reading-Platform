<template>
  <div v-if="totalPages > 1" class="pagination">
    <button
      type="button"
      class="page-btn"
      aria-label="上一页"
      :disabled="page <= 1"
      @click="$emit('change', page - 1)"
    >
      上一页
    </button>
    <span class="page-info" :aria-label="`第 ${page} 页`">{{ page }} / {{ totalPages }}</span>
    <button
      type="button"
      class="page-btn"
      aria-label="下一页"
      :disabled="page >= totalPages"
      @click="$emit('change', page + 1)"
    >
      下一页
    </button>
  </div>
</template>

<script setup lang="ts">
defineProps<{ page: number; totalPages: number }>()
defineEmits<{ change: [page: number] }>()
</script>

<style scoped>
.pagination {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-3);
  margin-top: var(--space-4);
}

.page-btn {
  min-height: 40px;
  padding: 0 18px;
  border: 1px solid var(--color-border);
  border-radius: var(--radius-pill);
  background: var(--color-surface);
  color: var(--color-text-2);
  font-size: var(--font-sm);
  transition: border-color 0.18s ease, color 0.18s ease, background-color 0.18s ease;
}

.page-btn:hover:not(:disabled) {
  border-color: var(--color-primary);
  color: var(--color-primary);
  background: var(--color-primary-soft);
}

.page-btn:disabled {
  opacity: 0.45;
  cursor: not-allowed;
}

.page-info {
  color: var(--color-text-3);
  font-size: var(--font-sm);
  min-width: 64px;
  text-align: center;
}
</style>