import { mount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import { beforeEach, describe, expect, it, vi } from 'vitest'

const routeState = {
  name: 'home' as string | symbol,
  path: '/',
  meta: {} as { nav?: 'home' | 'category' | 'bookshelf' | 'profile' },
}

vi.mock('vue-router', () => ({
  useRoute: () => routeState,
}))

import NavBar from '@/components/NavBar.vue'
import { useAuthStore } from '@/stores/auth'

function mountNav() {
  return mount(NavBar, {
    global: {
      stubs: {
        RouterLink: { template: '<a class="nav-link"><slot /></a>' },
      },
    },
  })
}

describe('NavBar', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
    routeState.name = 'home'
    routeState.path = '/'
    routeState.meta = {}
  })

  it('renders exactly four items in the fixed order when authenticated', () => {
    const store = useAuthStore()
    store.status = 'authenticated'
    const wrapper = mountNav()
    const labels = wrapper.findAll('.links a').map((item) => item.text())
    expect(labels).toEqual(['首页', '分类', '书架', '我的'])
  })

  it('keeps navigation available to visitors', () => {
    const store = useAuthStore()
    store.status = 'anonymous'
    const wrapper = mountNav()
    expect(wrapper.findAll('.links a')).toHaveLength(4)
    expect(wrapper.text()).not.toContain('登录')
  })

  it('highlights the item resolved from route meta', () => {
    const store = useAuthStore()
    store.status = 'authenticated'
    routeState.name = 'category-books'
    routeState.path = '/categories/cat-wuxia'
    routeState.meta = { nav: 'category' }
    const wrapper = mountNav()
    const items = wrapper.findAll('.links a')
    expect(items[1].classes()).toContain('is-active')
    expect(items[0].classes()).not.toContain('is-active')
  })

  it('keeps exactly one active item on content pages', () => {
    const store = useAuthStore()
    store.status = 'authenticated'
    routeState.name = 'reading'
    routeState.path = '/books/1/read/2'
    const wrapper = mountNav()
    const active = wrapper.findAll('.links a').filter((item) => item.classes().includes('is-active'))
    expect(active).toHaveLength(1)
    expect(active[0].text()).toBe('首页')
  })
})