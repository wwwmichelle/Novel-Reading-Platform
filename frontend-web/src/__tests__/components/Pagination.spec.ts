import { mount } from '@vue/test-utils'
import { describe, expect, it } from 'vitest'

import Pagination from '@/components/Pagination.vue'

describe('Pagination', () => {
  it('renders current page and total pages', () => {
    const wrapper = mount(Pagination, { props: { page: 2, totalPages: 5 } })
    expect(wrapper.text()).toContain('2 / 5')
  })

  it('is hidden when there is only one page', () => {
    const wrapper = mount(Pagination, { props: { page: 1, totalPages: 1 } })
    expect(wrapper.find('.pagination').exists()).toBe(false)
  })

  it('disables previous button on the first page', () => {
    const wrapper = mount(Pagination, { props: { page: 1, totalPages: 3 } })
    expect(wrapper.findAll('button')[0].attributes('disabled')).toBeDefined()
  })

  it('disables next button on the last page', () => {
    const wrapper = mount(Pagination, { props: { page: 3, totalPages: 3 } })
    expect(wrapper.findAll('button')[1].attributes('disabled')).toBeDefined()
  })

  it('emits change with the previous page', async () => {
    const wrapper = mount(Pagination, { props: { page: 2, totalPages: 3 } })
    await wrapper.findAll('button')[0].trigger('click')
    expect(wrapper.emitted('change')?.[0]).toEqual([1])
  })

  it('emits change with the next page', async () => {
    const wrapper = mount(Pagination, { props: { page: 1, totalPages: 3 } })
    await wrapper.findAll('button')[1].trigger('click')
    expect(wrapper.emitted('change')?.[0]).toEqual([2])
  })

  it('exposes accessible labels for both buttons', () => {
    const wrapper = mount(Pagination, { props: { page: 2, totalPages: 3 } })
    const buttons = wrapper.findAll('button')
    expect(buttons[0].attributes('aria-label')).toBe('上一页')
    expect(buttons[1].attributes('aria-label')).toBe('下一页')
  })

  it('announces the current page', () => {
    const wrapper = mount(Pagination, { props: { page: 2, totalPages: 3 } })
    expect(wrapper.find('.page-info').attributes('aria-label')).toBe('第 2 页')
  })
})