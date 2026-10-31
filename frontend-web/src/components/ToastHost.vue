<template>
  <div class="toast-host" aria-live="polite">
    <transition-group name="toast">
      <div v-for="item in toasts" :key="item.id" class="toast" :class="item.kind" role="status">
        <span class="toast-icon">{{ icon(item.kind) }}</span>
        <span class="toast-message">{{ item.message }}</span>
        <button class="toast-close" type="button" aria-label="关闭提示" @click="dismiss(item.id)">×</button>
      </div>
    </transition-group>
  </div>
</template>

<script setup lang="ts">
import { useToast } from '@/composables/useToast'
import type { ToastKind } from '@/stores/ui'

const { toasts, dismiss } = useToast()

function icon(kind: ToastKind) {
  if (kind === 'success') return '✓'
  if (kind === 'error') return '!'
  return 'i'
}
</script>

<style scoped>
.toast-host {
  position: fixed;
  top: calc(var(--nav-h) + 16px);
  right: 24px;
  z-index: 999;
  display: flex;
  flex-direction: column;
  gap: 10px;
  pointer-events: none;
}

.toast {
  display: flex;
  align-items: center;
  gap: 10px;
  min-width: 240px;
  max-width: 360px;
  padding: 12px 14px;
  border-radius: var(--radius-md);
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  box-shadow: var(--shadow-md);
  font-size: var(--font-sm);
  pointer-events: auto;
}

.toast.success {
  border-color: #bfe6d2;
}

.toast.error {
  border-color: #f2c4c4;
}

.toast-icon {
  display: grid;
  place-items: center;
  width: 22px;
  height: 22px;
  border-radius: 50%;
  font-size: 12px;
  font-weight: 700;
  color: #fff;
  background: var(--color-primary);
  flex-shrink: 0;
}

.toast.success .toast-icon {
  background: var(--color-success);
}

.toast.error .toast-icon {
  background: var(--color-danger);
}

.toast-message {
  flex: 1;
  color: var(--color-text);
}

.toast-close {
  border: none;
  background: transparent;
  color: var(--color-text-3);
  font-size: 18px;
  line-height: 1;
  padding: 0 2px;
}

.toast-enter-active,
.toast-leave-active {
  transition: opacity 0.2s ease, transform 0.2s ease;
}

.toast-enter-from,
.toast-leave-to {
  opacity: 0;
  transform: translateX(16px);
}

@media (max-width: 768px) {
  .toast-host {
    left: 16px;
    right: 16px;
  }

  .toast {
    max-width: none;
  }
}
</style>