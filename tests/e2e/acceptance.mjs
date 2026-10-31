import { createRequire } from 'node:module'
import fs from 'node:fs'
import path from 'node:path'
const { chromium } = createRequire(import.meta.url)('playwright-core')
const base = process.env.BASE_URL || 'http://localhost:8080'
const output = process.env.ARTIFACT_DIR || './artifacts'
fs.mkdirSync(output, { recursive: true })
const browser = await chromium.launch({ headless: true, executablePath: process.env.CHROME_PATH || 'C:/Program Files/Google/Chrome/Application/chrome.exe' })
const context = await browser.newContext({ viewport: { width: 1440, height: 900 } })
const page = await context.newPage()
page.setDefaultTimeout(20000)
const errors = []
page.on('pageerror', error => errors.push(error.message))
const results = []
function assert(value, message) { if (!value) throw new Error(message) }
async function step(name, fn) { await fn(); results.push(name); console.log('PASS ' + name) }
const username = 'reader_' + Date.now()
const password = 'ReaderTest2026!'
const commentText = '阅读验收 ' + username
let success = false
try {
  await step('Visitors browse 30 Chinese literature books and four categories', async () => {
    await page.goto(base)
    await page.locator('.book-card').first().waitFor()
    assert(await page.locator('.book-card').count() === 20, 'Expected 20 books on page one')
    await page.waitForTimeout(2000)
    await page.screenshot({ path: path.join(output, 'desktop-home.png'), fullPage: true })
    await page.getByRole('link', { name: '分类', exact: true }).click()
    await page.locator('.cat-card').first().waitFor()
    assert(await page.locator('.cat-card').count() === 4, 'Expected four categories')
    await page.locator('.cat-card').first().click()
    await page.locator('.book-card').first().waitFor()
  })
  await step('Home navigation works from detail and search finds real novels', async () => {
    await page.locator('.book-card').first().click()
    await page.locator('.book-detail h1').waitFor()
    await page.getByRole('link', { name: '首页', exact: true }).click()
    await page.locator('.search-bar input').fill('呐喊')
    await page.locator('.search-submit').click()
    await page.waitForFunction(() => document.querySelectorAll('.book-card').length === 1)
    await page.locator('.book-card').first().click()
    await page.locator('.book-detail h1').waitFor()
  })
  const detailPath = new URL(page.url()).pathname
  await step('Each contemporary novel exposes a real publisher link in a new tab', async () => {
    const source = page.getByRole('link', { name: '前往源网站阅读' })
    await source.waitFor()
    const href = await source.getAttribute('href')
    assert(/^https:\/\/www\.dedao\.cn\/ebook\/detail\?id=[a-zA-Z0-9]+$/.test(href), 'Invalid source URL')
    assert(await source.getAttribute('target') === '_blank', 'Original site must open separately')
  })
  await step('Login to registration retains the original book destination', async () => {
    await page.getByRole('button', { name: '加入书架', exact: true }).click()
    await page.locator('.login-page').waitFor()
    assert(new URL(page.url()).searchParams.get('redirect') === detailPath, 'Missing book redirect')
    await page.getByRole('link', { name: '没有账号？去注册' }).click()
    await page.locator('.register-page').waitFor()
    assert(new URL(page.url()).searchParams.get('redirect') === detailPath, 'Lost redirect on register')
    await page.locator('.register-page input').nth(0).fill(username)
    await page.locator('.register-page input').nth(1).fill(password)
    await page.locator('.register-page input').nth(2).fill(password)
    await page.locator('.register-page button[type=submit]').click()
    await page.locator('.book-detail h1').waitFor()
    assert(new URL(page.url()).pathname === detailPath, 'Registration did not return to book')
  })
  await step('Bookshelf and comments persist after reload', async () => {
    await page.getByRole('button', { name: '加入书架', exact: true }).click()
    await page.getByRole('button', { name: '移出书架', exact: true }).waitFor()
    await page.locator('.comment-form textarea').fill(commentText)
    await page.getByRole('button', { name: '发表评论', exact: true }).click()
    await page.getByText(commentText, { exact: true }).waitFor()
    await page.reload()
    await page.getByRole('button', { name: '移出书架', exact: true }).waitFor()
    await page.getByText(commentText, { exact: true }).waitFor()
    await page.getByRole('link', { name: '书架', exact: true }).click()
    await page.locator('.shelf-item').waitFor()
  })
  await step('Pagination exposes the remaining 10 novels', async () => {
    await page.goto(base + '/?page=2')
    await page.waitForFunction(() => document.querySelectorAll('.book-card').length === 10)
  })
  await step('Expired access token refreshes silently', async () => {
    await page.evaluate(() => localStorage.setItem('access_token', 'expired'))
    await page.goto(base + '/bookshelf')
    await page.locator('.shelf-item').waitFor()
    assert(await page.evaluate(() => localStorage.getItem('access_token')) !== 'expired', 'Token was not refreshed')
  })
  await step('Mobile layouts have no horizontal overflow', async () => {
    await page.setViewportSize({ width: 390, height: 844 })
    for (const [name, url, selector] of [['home', '/', '.book-card'], ['categories', '/categories', '.cat-card'], ['book', detailPath, '.book-detail h1'], ['shelf', '/bookshelf', '.shelf-item']]) {
      await page.goto(base + url)
      await page.locator(selector).first().waitFor()
      assert(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth), 'Overflow on ' + name)
      await page.screenshot({ path: path.join(output, 'mobile-' + name + '.png'), fullPage: true })
    }
  })
  await step('Logout clears state and incorrect login stays on the login page', async () => {
    await page.goto(base + '/profile')
    await page.getByRole('button', { name: '退出登录', exact: true }).click()
    await page.locator('.confirm-ok').click()
    await page.locator('.login-page').waitFor()
    assert(!await page.evaluate(() => localStorage.getItem('access_token')), 'Logout left tokens')
    await page.locator('.login-page input').nth(0).fill(username)
    await page.locator('.login-page input').nth(1).fill('wrong-password')
    await page.locator('.login-page button[type=submit]').click()
    await page.locator('.login-page .error').first().waitFor()
    assert(new URL(page.url()).pathname === '/login', 'Bad login caused navigation')
    await page.screenshot({ path: path.join(output, 'mobile-login.png'), fullPage: true })
    await page.locator('.login-page input').nth(1).fill(password)
    await page.locator('.login-page button[type=submit]').click()
    await page.locator('.book-card').first().waitFor()
  })
  assert(errors.length === 0, errors.join('\n'))
  fs.writeFileSync(path.join(output, 'acceptance.json'), JSON.stringify({ passed: results, pageErrors: errors }, null, 2))
  console.log('PASS ' + results.length + ' end-to-end scenarios; zero page errors')
  success = true
} catch (error) { console.error(error) } finally {
  await Promise.race([browser.close(), new Promise(resolve => setTimeout(resolve, 5000))])
  process.exit(success ? 0 : 1)
}
