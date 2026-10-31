<template>
  <div id="app">
    <SplashScreen v-if="showSplash" />
    <template v-else>
      <NavBar v-if="showNav" />
      <main :class="{ 'with-nav': showNav }">
        <router-view v-slot="{ Component }">
          <transition name="page-fade" mode="out-in">
            <component :is="Component" />
          </transition>
        </router-view>
      </main>
      <ToastHost />
      <ConfirmDialog />
    </template>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'

import ConfirmDialog from '@/components/ConfirmDialog.vue'
import NavBar from '@/components/NavBar.vue'
import SplashScreen from '@/components/SplashScreen.vue'
import ToastHost from '@/components/ToastHost.vue'
import { useAuthStore } from '@/stores/auth'

const route = useRoute()
const authStore = useAuthStore()

const isAuthPage = computed(() => ['login', 'register'].includes(String(route.name)))
const showSplash = computed(() => authStore.status === 'unknown')
const showNav = computed(() => !isAuthPage.value)
</script>

<style>
.with-nav {
  padding-top: 0;
}

.page-fade-enter-active,
.page-fade-leave-active {
  transition: opacity 0.18s ease, transform 0.18s ease;
}

.page-fade-enter-from {
  opacity: 0;
  transform: translateY(6px);
}

.page-fade-leave-to {
  opacity: 0;
  transform: translateY(-4px);
}

@media (prefers-reduced-motion: reduce) {
  .page-fade-enter-active,
  .page-fade-leave-active {
    transition: none;
  }
}
</style>
