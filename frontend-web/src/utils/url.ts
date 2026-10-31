const ALLOWED_IMAGE_PROTOCOLS = new Set(['http:', 'https:'])
const REJECTED_PREFIXES = ['//', 'data:', 'javascript:', 'vbscript:', 'file:', 'blob:']

export function isSafeImageUrl(raw: unknown): boolean {
  if (typeof raw !== 'string') return false
  const value = raw.trim()
  if (!value) return false
  const lowered = value.toLowerCase()
  if (REJECTED_PREFIXES.some((prefix) => lowered.startsWith(prefix))) return false
  try {
    const url = new URL(value)
    return ALLOWED_IMAGE_PROTOCOLS.has(url.protocol.toLowerCase())
  } catch {
    return false
  }
}

export function sanitizeRedirect(raw: unknown): string | null {
  if (typeof raw !== 'string') return null
  const value = raw.trim()
  if (!value.startsWith('/') || value.startsWith('//')) return null
  try {
    const base = 'http://novel.local'
    const url = new URL(value, base)
    if (url.origin !== base) return null
    const path = url.pathname.toLowerCase()
    if (path === '/login' || path === '/register') return null
    if (path.startsWith('/login/') || path.startsWith('/register/')) return null
    return value
  } catch {
    return null
  }
}
/** Allow only the specific official book-page routes used by the catalogue. */
export function isSafeSourceUrl(value: unknown): value is string {
  if (typeof value !== 'string') return false
  try {
    const url = new URL(value)
    if (url.protocol !== 'https:' || url.username || url.password || url.port || url.hash) return false
    if (url.hostname === 'www.dedao.cn') {
      const keys = [...url.searchParams.keys()]
      return url.pathname === '/ebook/detail' && keys.length === 1 && keys[0] === 'id' && /^[a-zA-Z0-9]+$/.test(url.searchParams.get('id') ?? '')
    }
    if (url.hostname === 'e.dangdang.com') return /^\/touch\/products\/\d+\.html$/.test(url.pathname) && !url.search
    return false
  } catch { return false }
}
