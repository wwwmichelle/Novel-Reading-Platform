import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useReadingStore = defineStore('reading', () => {
  const fontSize = ref(parseInt(localStorage.getItem('font_size') || '18'))
  const theme = ref<'light' | 'dark'>(localStorage.getItem('theme') as 'light' | 'dark' || 'light')

  function setFontSize(size: number) {
    fontSize.value = size
    localStorage.setItem('font_size', String(size))
  }

  function toggleTheme() {
    theme.value = theme.value === 'light' ? 'dark' : 'light'
    localStorage.setItem('theme', theme.value)
  }

  return { fontSize, theme, setFontSize, toggleTheme }
})