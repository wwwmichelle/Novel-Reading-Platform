<template>
  <div class="page-container">
    <div class="container">
      <slot />
    </div>
  </div>
</template>

<style scoped>
.page-container {
  width: 100%;
  padding: var(--space-5) 0;
}

@media (max-width: 768px) {
  .page-container {
    padding: var(--space-4) 0 var(--space-5);
  }
}
</style>