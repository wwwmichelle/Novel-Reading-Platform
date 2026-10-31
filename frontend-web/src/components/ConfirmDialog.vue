<template>
  <div v-if="ui.confirmState" class="confirm-mask" @click.self="handleCancel">
    <div
      class="confirm-dialog card"
      role="dialog"
      aria-modal="true"
      aria-labelledby="confirm-title"
      @keydown="handleKeydown"
    >
      <h3 id="confirm-title">{{ ui.confirmState.title }}</h3>
      <p class="confirm-message">{{ ui.confirmState.message }}</p>
      <div class="confirm-actions">
        <button ref="cancelRef" type="button" class="btn btn-ghost confirm-cancel" @click="handleCancel">
          {{ ui.confirmState.cancelText || '取消' }}
        </button>
        <button
          ref="okRef"
          type="button"
          class="btn confirm-ok"
          :class="ui.confirmState.danger ? 'btn-danger' : 'btn-primary'"
          @click="handleConfirm"
        >
          {{ ui.confirmState.confirmText || '确认' }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { nextTick, ref, watch } from 'vue'

import { useUiStore } from '@/stores/ui'

const ui = useUiStore()
const okRef = ref<HTMLButtonElement | null>(null)
const cancelRef = ref<HTMLButtonElement | null>(null)
let lastFocused: HTMLElement | null = null

watch(
  () => ui.confirmState,
  async (state) => {
    if (state) {
      lastFocused = document.activeElement as HTMLElement | null
      await nextTick()
      okRef.value?.focus()
    } else if (lastFocused) {
      lastFocused.focus()
      lastFocused = null
    }
  },
)

function handleConfirm() {
  ui.settleConfirm(true)
}

function handleCancel() {
  ui.settleConfirm(false)
}

function handleKeydown(event: KeyboardEvent) {
  if (event.key === 'Escape') {
    event.preventDefault()
    handleCancel()
    return
  }
  if (event.key === 'Tab') {
    const focusable = [cancelRef.value, okRef.value].filter(Boolean) as HTMLButtonElement[]
    if (focusable.length < 2) return
    const current = document.activeElement
    if (event.shiftKey && current === focusable[0]) {
      event.preventDefault()
      focusable[focusable.length - 1].focus()
    } else if (!event.shiftKey && current === focusable[focusable.length - 1]) {
      event.preventDefault()
      focusable[0].focus()
    }
  }
}
</script>

<style scoped>
.confirm-mask {
  position: fixed;
  inset: 0;
  z-index: 1000;
  display: grid;
  place-items: center;
  padding: 24px;
  background: rgba(15, 23, 36, 0.45);
  backdrop-filter: blur(2px);
}

.confirm-dialog {
  width: 100%;
  max-width: 380px;
  padding: 24px;
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-lg);
}

.confirm-dialog h3 {
  font-size: var(--font-md);
  margin-bottom: 8px;
}

.confirm-message {
  color: var(--color-text-2);
  font-size: var(--font-sm);
  line-height: 1.7;
  margin-bottom: 20px;
}

.confirm-actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}
</style>