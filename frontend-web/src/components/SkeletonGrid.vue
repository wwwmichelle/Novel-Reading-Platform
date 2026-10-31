<template>
  <div class="book-grid" aria-hidden="true">
    <div v-for="index in count" :key="index" class="skeleton-card card">
      <div class="skeleton-card__cover skeleton"></div>
      <div class="skeleton-card__info">
        <span class="skeleton-card__line skeleton"></span>
        <span class="skeleton-card__line short skeleton"></span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
withDefaults(defineProps<{ count?: number }>(), { count: 8 })
</script>

<style scoped>
.skeleton-card {
  overflow: hidden;
}

.skeleton-card__cover {
  width: 100%;
  aspect-ratio: 2 / 3;
  border-radius: 0;
}

.skeleton-card__info {
  display: flex;
  flex-direction: column;
  gap: 8px;
  padding: 12px 14px 16px;
}

.skeleton-card__line {
  height: 10px;
  width: 100%;
}

.skeleton-card__line.short {
  width: 62%;
}
</style>