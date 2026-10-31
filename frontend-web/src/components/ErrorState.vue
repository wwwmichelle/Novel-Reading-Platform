<template>
  <div class="error-state">
    <div class="error-icon" aria-hidden="true">!</div>
    <p class="error-message">{{ message }}</p>
    <button type="button" class="btn btn-soft" @click="$emit('retry')">{{ retryText }}</button>
  </div>
</template>

<script setup lang="ts">
withDefaults(defineProps<{ message?: string; retryText?: string }>(), {
  message: '加载失败',
  retryText: '重试',
})
defineEmits<{ retry: [] }>()
</script>

<style scoped>
.error-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
  padding: 48px 16px;
  text-align: center;
}

.error-icon {
  display: grid;
  place-items: center;
  width: 44px;
  height: 44px;
  border-radius: 50%;
  background: var(--color-danger-soft);
  color: var(--color-danger);
  font-weight: 700;
  font-size: 20px;
}

.error-message {
  color: var(--color-text-2);
  font-size: var(--font-sm);
}
</style>