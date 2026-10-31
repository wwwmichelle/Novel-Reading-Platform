<template>
  <div class="splash" aria-busy="true">
    <div class="splash__card">
      <div class="splash__mark">书</div>
      <p class="splash__title">小说阅读</p>
      <div class="splash__lines">
        <span class="skeleton"></span>
        <span class="skeleton"></span>
        <span class="skeleton short"></span>
      </div>
    </div>
  </div>
</template>

<style scoped>
.splash {
  display: grid;
  place-items: center;
  min-height: 100vh;
  background: var(--color-bg);
}

.splash__card {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
  width: 220px;
}

.splash__mark {
  display: grid;
  place-items: center;
  width: 52px;
  height: 52px;
  border-radius: 14px;
  background: linear-gradient(135deg, var(--color-primary), #5b8dff);
  color: #fff;
  font-size: 22px;
  font-weight: 700;
  box-shadow: 0 10px 24px rgba(47, 107, 255, 0.26);
}

.splash__title {
  font-size: var(--font-sm);
  color: var(--color-text-2);
  font-weight: 600;
}

.splash__lines {
  display: flex;
  flex-direction: column;
  gap: 8px;
  width: 100%;
  margin-top: 6px;
}

.splash__lines .skeleton {
  height: 10px;
  width: 100%;
}

.splash__lines .skeleton.short {
  width: 62%;
}
</style>