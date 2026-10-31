export interface PalettePair {
  from: string
  to: string
  text: string
}

export const COVER_REGISTRY: Record<string, string> = {
  山海经异闻录: '/covers/demo-001.svg',
  桃花源新记: '/covers/demo-002.svg',
  星河漫游者: '/covers/demo-003.svg',
  江湖夜雨十年灯: '/covers/demo-004.svg',
  雾中迷案: '/covers/demo-005.svg',
  月下花前集: '/covers/demo-006.svg',
}

export const PLACEHOLDER_PALETTE: PalettePair[] = [
  { from: '#243b6b', to: '#4f7fd1', text: '#ffffff' },
  { from: '#6d3b1f', to: '#c98a4b', text: '#fff7ea' },
  { from: '#1f3f5a', to: '#3f8fb0', text: '#eef7fb' },
  { from: '#4a2b56', to: '#9a6fb5', text: '#fbf4ff' },
  { from: '#234a3c', to: '#5aa88a', text: '#effaf5' },
  { from: '#6a2f3f', to: '#c0708a', text: '#fff2f5' },
  { from: '#3c3a55', to: '#7e7ab3', text: '#f4f3ff' },
  { from: '#5a4a1f', to: '#b8a04a', text: '#fffbe8' },
  { from: '#2f4a3c', to: '#5d7d63', text: '#f2faf4' },
  { from: '#4a3540', to: '#9a6575', text: '#fff3f7' },
  { from: '#28323f', to: '#5d738f', text: '#f0f5fb' },
  { from: '#5a3d2b', to: '#a67c52', text: '#fff8f0' },
]

export function normalizeTitle(title: string): string {
  return title
    .replace(/[\uFF01-\uFF5E]/g, (char) => String.fromCharCode(char.charCodeAt(0) - 0xfee0))
    .replace(/\u3000/g, ' ')
    .trim()
    .replace(/\s+/g, ' ')
}

export function builtinCoverFor(title: string): string | null {
  return COVER_REGISTRY[normalizeTitle(title)] ?? null
}