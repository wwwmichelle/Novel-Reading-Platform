import { ref } from 'vue'
import { defineStore } from 'pinia'

export type ToastKind = 'info' | 'success' | 'error'

export interface ToastItem {
  id: number
  message: string
  kind: ToastKind
}

export interface ConfirmOptions {
  title: string
  message: string
  confirmText?: string
  cancelText?: string
  danger?: boolean
}

interface ConfirmState extends ConfirmOptions {
  resolve: (value: boolean) => void
}

const MAX_TOASTS = 3
const TOAST_DURATION = 3000

export const useUiStore = defineStore('ui', () => {
  const toasts = ref<ToastItem[]>([])
  const confirmState = ref<ConfirmState | null>(null)
  const timers = new Map<number, ReturnType<typeof setTimeout>>()
  let seq = 0

  function dismissToast(id: number) {
    const timer = timers.get(id)
    if (timer) {
      clearTimeout(timer)
      timers.delete(id)
    }
    const index = toasts.value.findIndex((item) => item.id === id)
    if (index >= 0) toasts.value.splice(index, 1)
  }

  function showToast(message: string, kind: ToastKind = 'info') {
    const id = (seq += 1)
    toasts.value.push({ id, message, kind })
    while (toasts.value.length > MAX_TOASTS) {
      const oldest = toasts.value[0]
      dismissToast(oldest.id)
    }
    timers.set(
      id,
      setTimeout(() => dismissToast(id), TOAST_DURATION),
    )
  }

  function ask(options: ConfirmOptions): Promise<boolean> {
    if (confirmState.value) {
      confirmState.value.resolve(false)
      confirmState.value = null
    }
    return new Promise<boolean>((resolve) => {
      confirmState.value = { ...options, resolve }
    })
  }

  function settleConfirm(value: boolean) {
    const state = confirmState.value
    if (!state) return
    confirmState.value = null
    state.resolve(value)
  }

  function reset() {
    timers.forEach((timer) => clearTimeout(timer))
    timers.clear()
    toasts.value = []
    if (confirmState.value) {
      confirmState.value.resolve(false)
      confirmState.value = null
    }
  }

  return { toasts, confirmState, showToast, dismissToast, ask, settleConfirm, reset }
})