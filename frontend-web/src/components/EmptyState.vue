<template>
  <div class="empty-state">
    <div class="empty-art" aria-hidden="true">
      <span class="empty-book"></span>
    </div>
    <div class="empty-copy">
      <slot>
        <p class="empty-text">{{ message }}</p>
      </slot>
    </div>
  </div>
</template>

<script setup lang="ts">
withDefaults(defineProps<{ message?: string }>(), { message: '暂无内容' })
</script>

<style scoped>
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 14px;
  padding: 56px 16px;
  color: var(--color-text-2);
  text-align: center;
}

.empty-art {
  display: grid;
  place-items: center;
  width: 72px;
  height: 72px;
  border-radius: 50%;
  background: var(--color-surface-2);
}

.empty-book {
  width: 26px;
  height: 34px;
  border-radius: 3px;
  border: 2px solid var(--color-text-3);
  border-left-width: 6px;
  opacity: 0.7;
}

.empty-copy {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
  font-size: var(--font-sm);
}

.empty-text {
  color: var(--color-text-2);
}
</style>