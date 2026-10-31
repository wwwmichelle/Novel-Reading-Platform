import { useUiStore, type ToastKind } from '@/stores/ui'

export function useToast() {
  const ui = useUiStore()

  return {
    toasts: ui.toasts,
    push: (message: string, kind: ToastKind = 'info') => ui.showToast(message, kind),
    success: (message: string) => ui.showToast(message, 'success'),
    error: (message: string) => ui.showToast(message, 'error'),
    info: (message: string) => ui.showToast(message, 'info'),
    dismiss: (id: number) => ui.dismissToast(id),
  }
}