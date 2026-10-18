/**
 * 小程序「浏览器等效预览」服务（Node 原生，无第三方依赖）
 * ---------------------------------------------------------------------------
 * 作用：
 *   1) 把仓库根目录当静态站点发布，浏览器可直接读两个小程序的 *.js/*.wxml/*.wxss；
 *   2) 把 /api/** 反向代理到本地后端 http://localhost:8080/api/**（同源，避免 CORS 与
 *      「不校验合法域名」问题）；
 *   3) 提供 /preview/token 用本地 JWT 密钥签发**预览令牌**，让浏览器里也能以
 *      会员 / 渠道商身份调用需登录接口（微信 code2Session 在本机不可用时的替代方案）。
 *
 * 启动：node scripts/miniapp-preview/server.mjs [--port 8850] [--open]
 * 说明：只监听 127.0.0.1，仅用于本地开发调试，切勿部署到线上。
 */
import http from 'node:http'
import https from 'node:https'
import fs from 'node:fs'
import path from 'node:path'
import crypto from 'node:crypto'
import { fileURLToPath } from 'node:url'
import { spawn } from 'node:child_process'

const __dirname = path.dirname(fileURLToPath(import.meta.url))
const REPO_ROOT = path.resolve(__dirname, '..', '..')
const PREVIEW_DIR = __dirname

// ------------------------------ 参数 ------------------------------
function argValue(name, fallback) {
  const i = process.argv.indexOf(name)
  return i >= 0 && process.argv[i + 1] ? process.argv[i + 1] : fallback
}
const PORT = Number(argValue('--port', process.env.CRAB_PREVIEW_PORT || 8850))
const BACKEND = argValue('--backend', process.env.CRAB_BACKEND_ORIGIN || 'http://localhost:8080')
const BACKEND_URL = new URL(BACKEND)
const AUTO_OPEN = process.argv.includes('--open')

// 与后端 application.yml 的 crab.jwt.secret 保持一致（生产用环境变量覆盖；此处仅为本地预览）
const JWT_SECRET = process.env.CRAB_JWT_SECRET || 'xyGz-poyang-crab-2026-please-change-me-32bytes'

const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.mjs': 'text/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.wxml': 'text/plain; charset=utf-8',
  '.wxss': 'text/css; charset=utf-8',
  '.svg': 'image/svg+xml',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.gif': 'image/gif',
  '.webp': 'image/webp',
  '.ico': 'image/x-icon',
  '.map': 'application/json; charset=utf-8',
  '.md': 'text/plain; charset=utf-8'
}

// ------------------------------ 预览令牌 ------------------------------
function b64url(input) {
  return Buffer.from(input).toString('base64url')
}
function signPreviewToken({ app, id }) {
  // app=miniapp → 会员令牌；app=channel → 渠道商令牌（与后端 MemberAuthService / ChannelAuthService 签发结构一致）
  const isChannel = app === 'channel'
  const now = Math.floor(Date.now() / 1000)
  const payload = {
    sub: String(id),
    username: isChannel ? 'CHANNEL_PREVIEW_' + id : 'MEMBER_PREVIEW_' + id,
    loginType: isChannel ? 'CHANNEL' : 'MEMBER',
    roleType: isChannel ? 'CHANNEL' : 'MEMBER',
    channelId: isChannel ? Number(id) : 0,
    iat: now,
    exp: now + 86400
  }
  const head = b64url(JSON.stringify({ alg: 'HS256', typ: 'JWT' }))
  const body = b64url(JSON.stringify(payload))
  const sig = crypto.createHmac('sha256', JWT_SECRET).update(head + '.' + body).digest('base64url')
  return head + '.' + body + '.' + sig
}

// ------------------------------ 静态文件 ------------------------------
function sendFile(res, filePath) {
  fs.stat(filePath, (err, stat) => {
    if (err || !stat.isFile()) {
      res.writeHead(404, { 'Content-Type': 'application/json; charset=utf-8' })
      res.end(JSON.stringify({ code: 404, message: '文件不存在：' + path.relative(REPO_ROOT, filePath) }))
      return
    }
    const ext = path.extname(filePath).toLowerCase()
    res.writeHead(200, {
      'Content-Type': MIME[ext] || 'application/octet-stream',
      'Content-Length': stat.size,
      'Cache-Control': 'no-store'
    })
    fs.createReadStream(filePath).pipe(res)
  })
}

function safeJoin(root, urlPath) {
  const decoded = decodeURIComponent(urlPath.split('?')[0])
  const target = path.resolve(root, '.' + path.posix.normalize(decoded))
  if (!target.startsWith(root)) return null
  return target
}

// ------------------------------ 后端代理 ------------------------------
function proxyToBackend(req, res) {
  const target = new URL(req.url, BACKEND_URL)
  const client = target.protocol === 'https:' ? https : http
  const proxied = client.request({
    hostname: target.hostname,
    port: target.port || (target.protocol === 'https:' ? 443 : 80),
    path: target.pathname + target.search,
    method: req.method,
    headers: Object.assign({}, req.headers, { host: target.host })
  }, (upstream) => {
    res.writeHead(upstream.statusCode || 502, upstream.headers)
    upstream.pipe(res)
  })
  proxied.on('error', (err) => {
    res.writeHead(502, { 'Content-Type': 'application/json; charset=utf-8' })
    res.end(JSON.stringify({
      code: 502,
      message: '后端未启动或不可达（' + BACKEND + '）：' + err.message,
      success: false
    }))
  })
  req.pipe(proxied)
}

// ------------------------------ 路由 ------------------------------
function handle(req, res) {
  const url = req.url || '/'

  // 1) 预览令牌
  if (url.startsWith('/preview/token')) {
    const q = new URL(url, 'http://localhost').searchParams
    const app = q.get('app') === 'channel' ? 'channel' : 'miniapp'
    const id = Number(q.get('id') || 0)
    if (!id) {
      res.writeHead(200, { 'Content-Type': MIME['.json'], 'Cache-Control': 'no-store' })
      res.end(JSON.stringify({ token: '', app, id: 0 }))
      return
    }
    const token = signPreviewToken({ app, id })
    res.writeHead(200, { 'Content-Type': MIME['.json'], 'Cache-Control': 'no-store' })
    res.end(JSON.stringify({ token, app, id, expiresIn: 86400 }))
    return
  }

  // 2) 后端 API 代理
  if (url.startsWith('/api/') || url === '/api') {
    proxyToBackend(req, res)
    return
  }

  // 3) 预览页自身资源
  if (url === '/preview' || url.startsWith('/preview/')) {
    const rel = url.replace(/^\/preview\/?/, '')
    const file = safeJoin(PREVIEW_DIR, '/' + (rel || 'index.html'))
    if (!file) { res.writeHead(403); res.end('forbidden'); return }
    sendFile(res, file)
    return
  }

  // 4) 仓库静态文件（两个小程序的源码）
  if (url === '/') {
    res.writeHead(302, { Location: '/preview/' })
    res.end()
    return
  }
  const file = safeJoin(REPO_ROOT, url)
  if (!file) { res.writeHead(403); res.end('forbidden'); return }
  sendFile(res, file)
}

// ------------------------------ 启动 ------------------------------
const server = http.createServer((req, res) => {
  try {
    handle(req, res)
  } catch (err) {
    res.writeHead(500, { 'Content-Type': MIME['.json'] })
    res.end(JSON.stringify({ code: 500, message: String(err && err.message || err) }))
  }
})

server.listen(PORT, '127.0.0.1', () => {
  const url = `http://localhost:${PORT}/preview/`
  console.log('')
  console.log('  ===== 小程序浏览器预览 =====')
  console.log(`  预览地址   : ${url}`)
  console.log(`  静态根目录 : ${REPO_ROOT}`)
  console.log(`  后端代理   : /api/**  ->  ${BACKEND}/api/**`)
  console.log(`  C 端小程序 : ${url}#miniapp     (poyang-crab-miniapp)`)
  console.log(`  渠道商端   : ${url}#channel     (poyang-crab-channel)`)
  console.log('')
  console.log('  Ctrl+C 停止服务')
  console.log('')
  if (AUTO_OPEN) {
    spawn('cmd', ['/c', 'start', '', url], { detached: true, stdio: 'ignore' }).unref()
  }
})

server.on('error', (err) => {
  if (err.code === 'EADDRINUSE') {
    console.error(`[预览服务] 端口 ${PORT} 已被占用，请先停止占用进程或改用 --port 其它端口`)
  } else {
    console.error('[预览服务] 启动失败：', err)
  }
  process.exit(1)
})
