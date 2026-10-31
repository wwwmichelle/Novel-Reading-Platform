<template>
  <div class="cover">
    <div
      class="cover__placeholder"
      :style="{ background: `linear-gradient(140deg, ${palette.from}, ${palette.to})` }"
    >
      <span class="cover__watermark" :style="{ color: palette.text }">{{ initial }}</span>
      <span class="cover__title" :style="{ color: palette.text }">{{ cover.title }}</span>
      <span class="cover__author" :style="{ color: palette.text }">{{ cover.author || '佚名' }}</span>
    </div>
    <div v-if="visible && !loaded" class="cover__skeleton skeleton" aria-hidden="true"></div>
    <img
      v-if="visible"
      class="cover__img"
      :src="cover.src"
      :alt="cover.alt"
      :fetchpriority="priority ? 'high' : 'auto'"
      loading="lazy"
      decoding="async"
      @load="onLoad"
      @error="onError"
    />
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

import { paletteFor, useCover, type CoverInput } from '@/composables/useCover'

const props = withDefaults(defineProps<{ book: CoverInput; priority?: boolean }>(), {
  priority: false,
})

const { cover, visible, loaded, onError, onLoad } = useCover(props.book)
const palette = computed(() => paletteFor(cover.value))
const initial = computed(() => (cover.value.title || '书').trim().charAt(0))
</script>

<style scoped>
.cover {
  position: relative;
  width: 100%;
  aspect-ratio: 2 / 3;
  overflow: hidden;
  border-radius: var(--radius-md);
  background: var(--color-surface-2);
}

.cover__placeholder {
  position: absolute;
  inset: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 6px;
  padding: 12px;
  text-align: center;
}

.cover__watermark {
  position: absolute;
  font-size: 64px;
  font-weight: 700;
  opacity: 0.22;
  line-height: 1;
}

.cover__title {
  position: relative;
  font-size: var(--font-sm);
  font-weight: 600;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.cover__author {
  position: relative;
  font-size: var(--font-xs);
  opacity: 0.8;
}

.cover__skeleton {
  position: absolute;
  inset: 0;
}

.cover__img {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
}
</style>