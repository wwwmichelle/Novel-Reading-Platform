import { computed, ref } from 'vue'

import { builtinCoverFor, normalizeTitle, PLACEHOLDER_PALETTE } from '@/config/covers'
import type { CoverRef } from '@/types/api'
import { fnv1a } from '@/utils/hash'
import { isSafeImageUrl } from '@/utils/url'

const failedSources = new Set<string>()

function paletteIndex(title: string, author: string): number {
  const seed = `${normalizeTitle(title)}|${normalizeTitle(author)}`
  return fnv1a(seed) % PLACEHOLDER_PALETTE.length
}

export interface CoverInput {
  title: string
  author?: string | null
  cover_url?: string | null
}

export function resolveCover(book: CoverInput): CoverRef {
  const title = book.title ?? ''
  const author = book.author ?? ''
  const alt = `《${title}》，作者 ${author || '佚名'}`
  const index = paletteIndex(title, author)

  if (isSafeImageUrl(book.cover_url)) {
    return {
      kind: 'remote',
      src: String(book.cover_url).trim(),
      title,
      author,
      paletteIndex: index,
      alt,
    }
  }

  const builtin = builtinCoverFor(title)
  if (builtin) {
    return { kind: 'builtin', src: builtin, title, author, paletteIndex: index, alt }
  }

  return { kind: 'placeholder', title, author, paletteIndex: index, alt }
}

export function paletteFor(cover: CoverRef) {
  return PLACEHOLDER_PALETTE[cover.paletteIndex]
}

export function useCover(book: CoverInput) {
  const cover = computed(() => resolveCover(book))
  const failed = ref(false)
  const loaded = ref(false)

  const visible = computed(
    () => Boolean(cover.value.src) && !failed.value && !failedSources.has(cover.value.src ?? ''),
  )

  function onError() {
    const src = cover.value.src
    if (src) failedSources.add(src)
    failed.value = true
    loaded.value = false
  }

  function onLoad() {
    loaded.value = true
  }

  return { cover, failed, loaded, visible, onError, onLoad }
}

export function resetCoverFailures() {
  failedSources.clear()
}