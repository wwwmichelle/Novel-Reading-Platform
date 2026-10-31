import { mount } from '@vue/test-utils'
import { beforeEach, describe, expect, it } from 'vitest'

import CoverImage from '@/components/CoverImage.vue'
import { resetCoverFailures } from '@/composables/useCover'

const book = { title: '山海经异闻录', author: '佚名', cover_url: null }

describe('CoverImage', () => {
  beforeEach(() => resetCoverFailures())
  it('always renders the placeholder with title and author', () => {
    const wrapper = mount(CoverImage, { props: { book } })
    const placeholder = wrapper.find('.cover__placeholder')
    expect(placeholder.exists()).toBe(true)
    expect(placeholder.text()).toContain('山海经异闻录')
    expect(placeholder.text()).toContain('佚名')
  })

  it('renders the builtin cover image with a descriptive alt', () => {
    const wrapper = mount(CoverImage, { props: { book } })
    const img = wrapper.find('img')
    expect(img.exists()).toBe(true)
    expect(img.attributes('src')).toBe('/covers/demo-001.svg')
    expect(img.attributes('alt')).toContain('山海经异闻录')
    expect(img.attributes('alt')).toContain('佚名')
  })

  it('hides the image and keeps the placeholder after an error', async () => {
    const wrapper = mount(CoverImage, { props: { book } })
    expect(wrapper.find('img').exists()).toBe(true)
    await wrapper.find('img').trigger('error')
    expect(wrapper.find('img').exists()).toBe(false)
    expect(wrapper.find('.cover__placeholder').exists()).toBe(true)
  })

  it('shows a skeleton until the image loads', async () => {
    const wrapper = mount(CoverImage, { props: { book } })
    expect(wrapper.find('.cover__skeleton').exists()).toBe(true)
    await wrapper.find('img').trigger('load')
    expect(wrapper.find('.cover__skeleton').exists()).toBe(false)
  })
})