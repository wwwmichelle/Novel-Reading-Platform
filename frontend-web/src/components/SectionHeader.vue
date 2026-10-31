<template>
  <header id="search-result-anchor" class="section-header">
    <h2 class="section-title">
      <template v-if="mode === 'search'">
        搜索结果 · 「{{ keyword }}」 · 共 {{ total }} 本
      </template>
      <template v-else>书目浏览</template>
    </h2>
  </header>
</template>

<script setup lang="ts">
withDefaults(
  defineProps<{ mode: 'browse' | 'search'; keyword?: string; total?: number }>(),
  { keyword: '', total: 0 },
)
</script>

<style scoped>
.section-header {
  margin-bottom: var(--space-3);
}

.section-header .section-title {
  margin-bottom: 0;
}
</style>