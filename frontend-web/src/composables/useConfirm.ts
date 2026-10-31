import { useUiStore } from '@/stores/ui'

export function useConfirm() {
  const ui = useUiStore()

  return {
    ask: (options: {
      title: string
      message: string
      confirmText?: string
      cancelText?: string
      danger?: boolean
    }) => ui.ask(options),
  }
}