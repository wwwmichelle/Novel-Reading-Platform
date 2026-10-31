export interface CoverPlaceholder {
  initial: string
  from: string
  to: string
}

export interface ResolvedCover {
  src: string
  placeholder: CoverPlaceholder
}

const BUILTIN_COVERS: Record<string, string> = {
  山海经异闻录: '/covers/demo-001.svg',
  桃花源新记: '/covers/demo-002.svg',
  星河漫游者: '/covers/demo-003.svg',
  江湖夜雨十年灯: '/covers/demo-004.svg',
  雾中迷案: '/covers/demo-005.svg',
  月下花前集: '/covers/demo-006.svg',
}

const PALETTES: Array<[string, string]> = [
  ['#243b6b', '#4f7fd1'],
  ['#6d3b1f', '#c98a4b'],
  ['#1f3f5a', '#3f8fb0'],
  ['#4a2b56', '#9a6fb5'],
  ['#234a3c', '#5aa88a'],
  ['#6a2f3f', '#c0708a'],
  ['#3c3a55', '#7e7ab3'],
  ['#5a4a1f', '#b8a04a'],
]

export function isSafeCoverUrl(url: string | null | undefined): boolean {
  return typeof url === 'string' && /^https?:\/\//i.test(url.trim())
}

export function builtinCover(title: string): string {
  return BUILTIN_COVERS[title] ?? ''
}

function fnv1a(value: string): number {
  let hash = 0x811c9dc5
  for (let i = 0; i < value.length; i += 1) {
    hash ^= value.charCodeAt(i)
    hash = Math.imul(hash, 0x01000193)
  }
  return hash >>> 0
}

export function coverPlaceholder(title: string): CoverPlaceholder {
  const palette = PALETTES[fnv1a(title) % PALETTES.length]
  return {
    initial: title.trim().charAt(0) || '书',
    from: palette[0],
    to: palette[1],
  }
}

export function resolveCover(book: { title: string; cover_url?: string | null }): ResolvedCover {
  const remote = isSafeCoverUrl(book.cover_url) ? book.cover_url!.trim() : ''
  const src = remote || builtinCover(book.title)
  return {
    src,
    placeholder: coverPlaceholder(book.title),
  }
}