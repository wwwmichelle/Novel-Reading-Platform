<template>
  <nav class="navbar">
    <div class="nav-inner container">
      <router-link :to="brandTarget" class="logo">
        <span class="logo-mark">书</span>
        <span class="logo-text">小说阅读</span>
      </router-link>
      <div v-if="showItems" class="links">
        <router-link
          v-for="item in NAV_ITEMS"
          :key="item.key"
          :to="item.to"
          class="nav-link"
          :class="{ 'is-active': activeKey === item.key }"
        >
          {{ item.label }}
        </router-link>
      </div>
    </div>
  </nav>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'

import { NAV_ITEMS, resolveActiveNav } from '@/config/navigation'

const route = useRoute()

const showItems = computed(() => true)
const activeKey = computed(() => resolveActiveNav(route))
const brandTarget = '/'
</script>

<style scoped>
.navbar {
  position: sticky;
  top: 0;
  z-index: 100;
  height: var(--nav-h);
  background: rgba(255, 255, 255, 0.92);
  backdrop-filter: blur(12px);
  border-bottom: 1px solid var(--color-border);
}

.nav-inner {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 100%;
}

.logo {
  display: inline-flex;
  align-items: center;
  gap: 10px;
  font-size: var(--font-md);
  font-weight: 700;
  color: var(--color-text);
}

.logo-mark {
  display: grid;
  place-items: center;
  width: 34px;
  height: 34px;
  border-radius: 10px;
  background: linear-gradient(135deg, var(--color-primary), #5b8dff);
  color: #fff;
  font-size: 16px;
  box-shadow: 0 6px 14px rgba(47, 107, 255, 0.28);
}

.links {
  display: flex;
  align-items: center;
  gap: 6px;
}

.links a.nav-link {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 72px;
  min-height: 44px;
  padding: 0 14px;
  border-radius: var(--radius-pill);
  color: var(--color-text-2);
  font-size: var(--font-sm);
  transition: color 0.18s ease, background-color 0.18s ease;
}

.links a.nav-link:hover {
  color: var(--color-primary);
  background: var(--color-primary-soft);
}

.links a.nav-link.is-active {
  color: var(--color-primary);
  background: var(--color-primary-soft);
  font-weight: 600;
}

@media (max-width: 768px) {
  .logo-text {
    display: none;
  }

  .links {
    gap: 2px;
  }

  .links a.nav-link {
    min-width: 60px;
    min-height: 44px;
    padding: 0 8px;
    font-size: var(--font-xs);
  }
}
</style>
