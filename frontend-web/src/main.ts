import { createApp } from 'vue'
import { createPinia } from 'pinia'

import App from './App.vue'
import router from './router'
import { AUTH_DEGRADED_EVENT, AUTH_INVALID_EVENT } from './api/request'
import { useAuthStore } from './stores/auth'
import './styles/index.css'

const app = createApp(App)
app.use(createPinia())

const authStore = useAuthStore()

window.addEventListener(AUTH_INVALID_EVENT, () => {
  authStore.markInvalid()
  const current = router.currentRoute.value
  if (current.meta.requiresAuth) {
    router.replace({ name: 'login', query: { redirect: current.fullPath, reason: 'expired' } })
  }
})

window.addEventListener(AUTH_DEGRADED_EVENT, () => {
  authStore.markDegraded()
})

window.addEventListener('storage', (event) => {
  if (event.key !== 'access_token' && event.key !== null) return
  authStore.syncFromStorage()
  if (!authStore.isLoggedIn && router.currentRoute.value.meta.requiresAuth) {
    router.replace({ name: 'login', query: { redirect: router.currentRoute.value.fullPath } })
  }
})

authStore.bootstrap()

app.use(router)
app.mount('#app')