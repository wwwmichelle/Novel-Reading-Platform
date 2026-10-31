import { mount } from '@vue/test-utils'
import { h } from 'vue'
import { describe, expect, it, vi } from 'vitest'

import EmptyState from '@/components/EmptyState.vue'
import ErrorState from '@/components/ErrorState.vue'

describe('ErrorState', () => {
  it('renders the error message', () => {
    const wrapper = mount(ErrorState, { props: { message: '网络连接失败' } })
    expect(wrapper.text()).toContain('网络连接失败')
  })

  it('emits retry when the retry button is clicked', async () => {
    const wrapper = mount(ErrorState, { props: { message: '加载失败' } })
    await wrapper.find('button').trigger('click')
    expect(wrapper.emitted('retry')).toHaveLength(1)
  })

  it('supports a custom retry button label', () => {
    const wrapper = mount(ErrorState, { props: { message: 'x', retryText: '重新加载' } })
    expect(wrapper.find('button').text()).toBe('重新加载')
  })
})

describe('EmptyState', () => {
  it('renders the default empty message', () => {
    const wrapper = mount(EmptyState)
    expect(wrapper.find('.empty-state').exists()).toBe(true)
  })

  it('renders a custom message', () => {
    const wrapper = mount(EmptyState, { props: { message: '暂无图书' } })
    expect(wrapper.text()).toContain('暂无图书')
  })

  it('renders an action slot that can trigger parent handlers', async () => {
    const onAction = vi.fn()
    const wrapper = mount(EmptyState, {
      slots: {
        default: () =>
          h('button', { class: 'action', onClick: onAction }, '去浏览书目'),
      },
    })
    await wrapper.find('.action').trigger('click')
    expect(onAction).toHaveBeenCalledTimes(1)
  })
})