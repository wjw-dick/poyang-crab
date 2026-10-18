/* eslint-disable no-new-func */
/**
 * 微信小程序「浏览器等效预览」运行时（仅开发调试用，不参与小程序打包）
 * ---------------------------------------------------------------------------
 * 本机没有安装微信开发者工具时，用浏览器直接按**真实 WXML / WXSS / JS** 渲染
 * poyang-crab-miniapp（C 端）与 poyang-crab-channel（渠道商端）：
 *   - JS  ：同步 XHR 拉取源码 + CommonJS require，真实执行 App()/Page()/setData
 *   - WXML：{{}} 插值、wx:if/elif/else、wx:for(+item/index/key)、bindtap、catchtap 事件
 *   - WXSS：rpx -> px（375 宽视口，1rpx = 0.5px）、page -> :host、image -> img
 *   - wx  ：request/uploadFile/login/存储/导航/弹窗等常用 API 的浏览器实现
 *   - 网络：请求统一改写为同源 /api/**，由 preview-server.mjs 代理到后端 8080（无跨域问题）
 *   - 登录：由预览页注入「本地签发的预览令牌」（见 preview-server.mjs /preview/token）
 *
 * 渲染在 Shadow DOM 内，页面样式不会污染预览页；页面之间可点击跳转（含 tabBar / 返回）。
 * 注意：这不是微信运行时的完整替代，个别能力（支付、真实摄像头、订阅消息等）只做模拟。
 */
;(function (global) {
  'use strict'

  var STORE_PREFIX = '__mini__:'                 // localStorage 命名空间，与预览页保持一致
  var RPX = 0.5                                  // 375px 视口下 1rpx = 0.5px
  var PLACEHOLDER_IMG = svgPlaceholder('湖蟹图片')

  // ============================ 小工具 ============================
  function storageKey(appKey, key) {
    return STORE_PREFIX + appKey + ':' + key
  }

  function svgPlaceholder(label) {
    var svg =
      '<svg xmlns="http://www.w3.org/2000/svg" width="240" height="240">' +
      '<rect width="240" height="240" fill="#EDF1F7"/>' +
      '<circle cx="120" cy="104" r="34" fill="#DDE5F0"/>' +
      '<text x="120" y="176" font-size="22" fill="#9AA7BD" text-anchor="middle" ' +
      'font-family="PingFang SC,Microsoft YaHei,sans-serif">' + label + '</text></svg>'
    return 'data:image/svg+xml;charset=utf-8,' + encodeURIComponent(svg)
  }

  function escapeHtml(str) {
    return String(str == null ? '' : str)
      .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;').replace(/'/g, '&#39;')
  }

  // ---------- 表达式求值（WXML 里的 {{ }}） ----------
  var exprCache = Object.create(null)
  function compileExpr(expr) {
    var fn = exprCache[expr]
    if (!fn) {
      try {
        fn = new Function('$s', 'with ($s) { return (' + expr + ') }')
      } catch (e) {
        fn = function () { return undefined }
      }
      exprCache[expr] = fn
    }
    return fn
  }

  function evalExpr(expr, scope) {
    if (expr === undefined || expr === null) return undefined
    var src = String(expr).trim()
    if (!src) return ''
    try {
      return compileExpr(src)(scope)
    } catch (e) {
      return undefined
    }
  }

  var MUSTACHE = /\{\{([\s\S]*?)\}\}/g
  function interpolate(str, scope) {
    if (typeof str !== 'string' || str.indexOf('{{') < 0) return str
    return str.replace(MUSTACHE, function (m, expr) {
      var v = evalExpr(expr, scope)
      if (v === undefined || v === null || v === false) return ''
      return String(v)
    })
  }

  function truthy(v) {
    return !(v === undefined || v === null || v === false || v === '' || v === 0 || v === '0')
  }

  // ---------- WXSS 转换：rpx / page / image ----------
  function transformWxss(css) {
    if (!css) return ''
    return String(css)
      .replace(/(-?\d*\.?\d+)rpx/g, function (m, n) { return (parseFloat(n) * RPX) + 'px' })
      .replace(/(?<=^|[\s,{}>+~])page(?=[\s,{>+~:.#\[]|$)/gm, ':host')
      .replace(/(?<=^|[\s,{}>+~])image(?=[\s,{>+~:.#\[]|$)/gm, 'img')
  }

  // ---------- setData 路径赋值 ----------
  function setByPath(obj, path, value) {
    var parts = String(path).replace(/\[(\d+)\]/g, '.$1').split('.')
    var cur = obj
    for (var i = 0; i < parts.length - 1; i++) {
      var k = parts[i]
      if (cur[k] === undefined || cur[k] === null) cur[k] = {}
      cur = cur[k]
    }
    cur[parts[parts.length - 1]] = value
  }

  function clone(value) {
    if (value === undefined || value === null) return value
    try { return JSON.parse(JSON.stringify(value)) } catch (e) { return value }
  }

  // ============================ 基础样式 ============================
  var BASE_CSS = [
    ':host{display:block;height:100%;font-family:-apple-system,BlinkMacSystemFont,"Helvetica Neue","PingFang SC","Microsoft YaHei",sans-serif;}',
    'view,scroll-view,swiper,swiper-item,rich-text,picker,checkbox-group,form{display:block;}',
    'text{display:inline;}',
    'img{display:inline-block;vertical-align:middle;}',
    'button{display:block;margin:0;padding:0;border:0;background:none;color:inherit;font:inherit;text-align:center;}',
    'input,textarea{display:inline-block;border:0;outline:none;background:transparent;font:inherit;color:inherit;width:100%;}',
    '.mini-root{position:relative;height:100%;overflow:hidden;transform:translateZ(0);}',
    '.mini-scroll{height:100%;overflow-y:auto;overflow-x:hidden;}',
    '.mini-body{position:relative;min-height:100%;}',
    '.__scroll-x{overflow-x:auto;overflow-y:hidden;white-space:nowrap;}',
    '.mini-overlay{position:absolute;left:0;top:0;right:0;bottom:0;pointer-events:none;z-index:9999;}',
    '.mini-overlay>*{pointer-events:auto;}',
    '.mini-toast{position:absolute;left:50%;top:50%;transform:translate(-50%,-50%);background:rgba(0,0,0,.75);color:#fff;font-size:13px;line-height:1.4;padding:10px 16px;border-radius:6px;max-width:70%;text-align:center;}',
    '.mini-loading{position:absolute;left:50%;top:50%;transform:translate(-50%,-50%);background:rgba(0,0,0,.7);color:#fff;font-size:12px;padding:12px 18px;border-radius:8px;}',
    '.mini-modal{position:absolute;left:0;top:0;right:0;bottom:0;background:rgba(0,0,0,.35);display:flex;align-items:center;justify-content:center;}',
    '.mini-modal-box{width:76%;background:#fff;border-radius:10px;overflow:hidden;}',
    '.mini-modal-title{font-size:15px;font-weight:600;text-align:center;padding:18px 16px 6px;color:#1F1F1F;}',
    '.mini-modal-content{font-size:13px;color:#666;text-align:center;padding:8px 16px 18px;line-height:1.6;word-break:break-all;max-height:50vh;overflow:auto;}',
    '.mini-modal-btns{display:flex;border-top:1px solid #EDEDED;}',
    '.mini-modal-btns div{flex:1;text-align:center;padding:12px 0;font-size:15px;cursor:pointer;color:#333;}',
    '.mini-modal-btns div+div{border-left:1px solid #EDEDED;color:#07C160;}',
    '.mini-viewer{position:absolute;left:0;top:0;right:0;bottom:0;background:rgba(0,0,0,.92);display:flex;align-items:center;justify-content:center;}',
    '.mini-viewer img{max-width:100%;max-height:100%;object-fit:contain;}',
    '.mini-empty{padding:60px 0;text-align:center;color:#B9C2CF;font-size:13px;}'
  ].join('\n')

  // ============================ WXML 渲染 ============================
  var EVENTS = {
    tap: 'click',
    longpress: 'contextmenu',
    longtap: 'contextmenu',
    input: 'input',
    confirm: 'keydown',
    change: 'change',
    blur: 'blur',
    focus: 'focus',
    submit: 'click',
    scroll: 'scroll',
    getphonenumber: 'click',
    getuserinfo: 'click',
    load: 'load',
    error: 'error'
  }

  function parseWxml(text) {
    var doc = new DOMParser().parseFromString(
      '<div id="__wxml_root">' + text + '</div>', 'text/html')
    var root = doc.getElementById('__wxml_root')
    var frag = doc.createDocumentFragment()
    while (root.firstChild) frag.appendChild(root.firstChild)
    return frag
  }

  function camelData(name) {
    return name.replace(/-([a-z])/g, function (m, c) { return c.toUpperCase() })
  }

  function renderChildren(container, scope, parent, ctx) {
    var nodes = Array.prototype.slice.call(container.childNodes)
    var ifTaken = null
    for (var i = 0; i < nodes.length; i++) {
      var node = nodes[i]
      if (node.nodeType === 3) {
        var text = interpolate(node.nodeValue, scope)
        if (text) parent.appendChild(document.createTextNode(text))
        continue
      }
      if (node.nodeType !== 1) continue
      var hasIf = node.hasAttribute('wx:if')
      var hasElif = node.hasAttribute('wx:elif')
      var hasElse = node.hasAttribute('wx:else')
      if (hasIf || hasElif || hasElse) {
        var show
        if (hasIf) {
          show = truthy(evalExpr(node.getAttribute('wx:if'), scope))
          ifTaken = show
        } else if (hasElif) {
          show = !ifTaken && truthy(evalExpr(node.getAttribute('wx:elif'), scope))
          if (show) ifTaken = true
        } else {
          show = !ifTaken
          ifTaken = true
        }
        if (!show) continue
      } else {
        ifTaken = null
      }
      renderElement(node, scope, parent, ctx)
    }
  }

  function renderElement(node, scope, parent, ctx) {
    // wx:for 优先（同一元素上的 wx:if 在每项作用域内再判断）
    var forExpr = node.getAttribute('wx:for')
    if (forExpr !== null) {
      var list = evalExpr(forExpr, scope)
      var arr = Array.isArray(list)
        ? list
        : (list && typeof list === 'object' ? Object.keys(list).map(function (k) { return list[k] }) : [])
      var itemName = node.getAttribute('wx:for-item') || 'item'
      var indexName = node.getAttribute('wx:for-index') || 'index'
      for (var i = 0; i < arr.length; i++) {
        var childScope = Object.create(scope)
        childScope[itemName] = arr[i]
        childScope[indexName] = i
        var cloneNode = node.cloneNode(true)
        cloneNode.removeAttribute('wx:for')
        cloneNode.removeAttribute('wx:for-item')
        cloneNode.removeAttribute('wx:for-index')
        cloneNode.removeAttribute('wx:key')
        renderElement(cloneNode, childScope, parent, ctx)
      }
      return
    }
    if (node.hasAttribute('wx:if') && !truthy(evalExpr(node.getAttribute('wx:if'), scope))) return

    var tag = node.tagName.toLowerCase()
    if (tag === 'block' || tag === 'template') {
      renderChildren(node, scope, parent, ctx)
      return
    }

    var el = createEl(tag)
    bindAttrs(el, node, scope)
    bindEvents(el, node, scope, ctx)

    if (tag === 'rich-text') {
      var nodes = node.getAttribute('nodes') || node.getAttribute('content') || ''
      el.innerHTML = String(interpolate(nodes, scope) || '')
    } else {
      renderChildren(node, scope, el, ctx)
    }
    parent.appendChild(el)
  }

  function createEl(tag) {
    var mapped = tag === 'image' ? 'img' : tag
    return document.createElement(mapped)
  }

  var SKIP_ATTR = /^(wx:|bind|catch|data-)/

  function bindAttrs(el, node, scope) {
    var attrs = Array.prototype.slice.call(node.attributes)
    var dataset = {}
    for (var i = 0; i < attrs.length; i++) {
      var name = attrs[i].name
      var raw = attrs[i].value
      if (name.indexOf('data-') === 0) {
        dataset[camelData(name.slice(5))] = interpolate(raw, scope)
        continue
      }
      if (SKIP_ATTR.test(name)) continue
      var value = interpolate(raw, scope)
      switch (name) {
        case 'class':
          el.className = value
          break
        case 'style':
          el.setAttribute('style', value)
          break
        case 'hidden':
          if (truthy(value)) el.style.display = 'none'
          break
        case 'id':
          el.setAttribute('id', value)
          break
        case 'mode':
          if (el.tagName === 'IMG') {
            if (value === 'aspectFill') el.style.objectFit = 'cover'
            else if (value === 'aspectFit') el.style.objectFit = 'contain'
            else if (value === 'widthFix') { el.style.width = '100%'; el.style.height = 'auto'; }
            else if (value === 'heightFix') { el.style.height = '100%'; el.style.width = 'auto'; }
          }
          break
        case 'src':
          if (el.tagName === 'IMG') {
            el.style.overflow = 'hidden'
            if (value) {
              el.src = value
              el.addEventListener('error', function () { el.src = PLACEHOLDER_IMG }, { once: true })
            } else {
              el.src = PLACEHOLDER_IMG
              el.classList.add('__mini-ph')
            }
          } else {
            el.setAttribute('src', value)
          }
          break
        case 'scroll-x':
          if (truthy(value)) el.classList.add('__scroll-x')
          break
        case 'scroll-into-view': case 'enable-flex': case 'show-scrollbar': case 'enhanced':
        case 'lazy-load': case 'catch-bubbling': case 'cursor-spacing': case 'confirm-type':
        case 'confirm-hold': case 'adjust-position': case 'placeholder-class': case 'placeholder-style':
        case 'maxlength': case 'auto-height': case 'show-confirm-bar': case 'disable-default-padding':
        case 'scroll-with-animation': case 'duration': case 'autoplay': case 'interval': case 'circular':
        case 'indicator-dots': case 'current': case 'range-key': case 'display-multiple-items':
          break
        case 'value':
          if (el.tagName === 'INPUT' || el.tagName === 'TEXTAREA') {
            if (document.activeElement !== el && el.value !== value) el.value = value
          } else {
            el.setAttribute('data-value', value)
          }
          break
        case 'placeholder':
          if (el.tagName === 'INPUT' || el.tagName === 'TEXTAREA') el.placeholder = value
          break
        case 'disabled':
          if (truthy(value)) el.setAttribute('disabled', 'disabled')
          break
        case 'type':
          if (el.tagName === 'INPUT') el.type = value === 'number' || value === 'digit' ? 'number' : (value === 'idcard' ? 'text' : value)
          break
        default:
          // 其余属性（picker 的 mode/value 等）保留到 dataset，事件里可读
          el.setAttribute('data-' + name, value)
      }
    }
    el.__miniDataset = dataset
  }

  function bindEvents(el, node, scope, ctx) {
    var attrs = Array.prototype.slice.call(node.attributes)
    for (var i = 0; i < attrs.length; i++) {
      var name = attrs[i].name
      var m = /^(bind|catch):?([A-Za-z]+)$/.exec(name)
      if (!m) continue
      var kind = m[2].toLowerCase()
      var isCatch = m[1] === 'catch'
      var domEvent = EVENTS[kind] || kind
      var handlerName = String(attrs[i].value).trim()
      if (!handlerName) continue
      el.setAttribute('data-__mini-bind-' + kind, handlerName)
      ;(function (kind, isCatch, domEvent, handlerName) {
        el.addEventListener(domEvent, function (ev) {
          if (isCatch) ev.stopPropagation()
          if (domEvent === 'keydown' && ev.key !== 'Enter') return
          var page = ctx.page
          var fn = page && page[handlerName]
          var detail = {}
          if (kind === 'input' || kind === 'confirm' || kind === 'blur' || kind === 'focus') {
            detail.value = ev.target && 'value' in ev.target ? ev.target.value : ''
          } else if (kind === 'change') {
            if (ev.target && ev.target.type === 'checkbox') {
              detail.value = ev.target.checked
            } else {
              detail.value = ev.target && 'value' in ev.target ? ev.target.value : ''
            }
          } else if (kind === 'scroll') {
            detail.scrollTop = ev.target ? ev.target.scrollTop : 0
          } else if (kind === 'getphonenumber') {
            detail.code = 'PREVIEW_PHONE_CODE'
            detail.encryptedData = 'preview-encrypted-data'
            detail.iv = 'preview-iv'
          } else if (kind === 'tap' || kind === 'longpress') {
            var touch = (ev.touches && ev.touches[0]) || ev
            detail.x = touch.clientX || 0
            detail.y = touch.clientY || 0
          }
          if (typeof fn !== 'function') {
            ctx.log('warn', '页面未实现事件 ' + handlerName + '()', null)
            return
          }
          var dataset = el.__miniDataset || {}
          var synthetic = {
            type: kind,
            detail: detail,
            currentTarget: { id: el.id || '', dataset: dataset },
            target: { id: el.id || '', dataset: dataset }
          }
          try {
            fn.call(page, synthetic)
          } catch (e) {
            ctx.log('error', '事件 ' + handlerName + '() 抛错：' + e.message, null)
            console.error('[mini-preview] ' + handlerName, e)
          }
        })
      })(kind, isCatch, domEvent, handlerName)
    }
  }

  // ============================ 应用实例 ============================
  function createApp(options) {
    var appKey = options.appKey
    var rootUrl = options.rootUrl.replace(/\/?$/, '/')
    var ctx = {
      appKey: appKey,
      app: null,
      page: null,
      log: options.log || function () {}
    }

    function key(k) { return storageKey(appKey, k) }

    // ---------- 源码加载 ----------
    var textCache = Object.create(null)
    function fetchTextSync(url) {
      if (url in textCache) return textCache[url]
      var xhr = new XMLHttpRequest()
      xhr.open('GET', url, false)
      try { xhr.send(null) } catch (e) { textCache[url] = ''; return '' }
      var text = xhr.status >= 200 && xhr.status < 300 ? xhr.responseText : ''
      textCache[url] = text
      return text
    }
    function dropCache() { textCache = Object.create(null) }

    var app = {
      key: appKey,
      shadow: null,
      host: options.host,
      appJson: {},
      appWxss: '',
      appInstance: null,
      pageStack: [],
      onTitle: options.onTitle || function () {},
      onTabbar: options.onTabbar || function () {},
      onRoute: options.onRoute || function () {}
    }

    // ---------- 模块系统（CommonJS + 同步 XHR） ----------
    var modules = Object.create(null)
    function loadModule(url) {
      if (url in modules) return modules[url].exports
      var mod = { exports: {} }
      modules[url] = mod
      var src = fetchTextSync(url)
      if (!src) {
        ctx.log('error', '模块加载失败（404？）：' + url, null)
        return mod.exports
      }
      var dir = url.slice(0, url.lastIndexOf('/') + 1)
      function requireFn(rel) {
        var target
        try { target = new URL(rel, dir).href } catch (e) { throw new Error('require 路径非法：' + rel) }
        if (!/\.js(\?|$)/.test(target)) target += '.js'
        return loadModule(target)
      }
      try {
        var fn = new Function(
          'module', 'exports', 'require', 'wx', 'App', 'Page', 'Component', 'getApp',
          'getCurrentPages', 'console', 'setTimeout', 'clearTimeout', 'setInterval', 'clearInterval',
          src + '\n//# sourceURL=' + url
        )
        fn.call(global, mod, mod.exports, requireFn, app.wx, app.__App, app.__Page, function () { return null },
          function () { return app.pageStack }, console, global.setTimeout, global.clearTimeout,
          global.setInterval, global.clearInterval)
      } catch (e) {
        ctx.log('error', '模块执行失败：' + url + ' → ' + e.message, null)
        console.error('[mini-preview] module', url, e)
      }
      return mod.exports
    }

    // ---------- App() / Page() ----------
    var pendingPage = null
    app.__App = function (opts) {
      app.appOptions = opts
      var instance = Object.assign({}, opts)
      app.appInstance = instance
      try { instance.onLaunch && instance.onLaunch({ path: '', query: {} }) } catch (e) { console.error(e) }
      try { instance.onShow && instance.onShow({}) } catch (e) { console.error(e) }
    }
    app.__Page = function (opts) { pendingPage = opts }

    // ---------- 页面容器 ----------
    function ensureShadow() {
      if (app.shadow) return
      app.shadow = app.host.attachShadow({ mode: 'open' })
      app.styleEl = document.createElement('style')
      app.shadow.appendChild(app.styleEl)
      app.rootEl = document.createElement('div')
      app.rootEl.className = 'mini-root'
      app.scrollEl = document.createElement('div')
      app.scrollEl.className = 'mini-scroll'
      app.bodyEl = document.createElement('div')
      app.bodyEl.className = 'mini-body'
      app.scrollEl.appendChild(app.bodyEl)
      app.rootEl.appendChild(app.scrollEl)
      app.shadow.appendChild(app.rootEl)
      app.overlayEl = document.createElement('div')
      app.overlayEl.className = 'mini-overlay'
      app.shadow.appendChild(app.overlayEl)
    }

    // 重渲染前记录焦点/滚动，渲染后还原（否则输入框每敲一个字就失焦）
    function pathOf(el, root) {
      var path = []
      while (el && el !== root) {
        var parent = el.parentNode
        if (!parent) return null
        path.unshift(Array.prototype.indexOf.call(parent.childNodes, el))
        el = parent
      }
      return path
    }
    function byPath(root, path) {
      var el = root
      for (var i = 0; i < path.length; i++) {
        el = el.childNodes[path[i]]
        if (!el) return null
      }
      return el
    }

    function render() {
      ensureShadow()
      var page = app.page
      if (!page) return
      ensureShadow()
      app.styleEl.textContent = BASE_CSS + '\n' + transformWxss(app.appWxss) + '\n' + transformWxss(app.pageWxss || '')

      var active = app.shadow.activeElement
      var focusPath = active && active !== app.bodyEl ? pathOf(active, app.bodyEl) : null
      var caret = null
      try { if (active && active.selectionStart != null) caret = [active.selectionStart, active.selectionEnd] } catch (e) { }
      var scrollTop = app.scrollEl.scrollTop
      var scrollLefts = {}
      Array.prototype.forEach.call(app.bodyEl.querySelectorAll('.__scroll-x'), function (el, i) {
        scrollLefts[i] = el.scrollLeft
      })

      app.bodyEl.innerHTML = ''
      var scope = Object.create(null)
      Object.keys(page.data || {}).forEach(function (k) { scope[k] = page.data[k] })
      ctx.page = page
      try {
        renderChildren(app.tpl, scope, app.bodyEl, ctx)
      } catch (e) {
        ctx.log('error', 'WXML 渲染失败：' + e.message, null)
        console.error('[mini-preview] render', e)
      }

      app.scrollEl.scrollTop = scrollTop
      Array.prototype.forEach.call(app.bodyEl.querySelectorAll('.__scroll-x'), function (el, i) {
        if (scrollLefts[i] != null) el.scrollLeft = scrollLefts[i]
      })
      if (focusPath) {
        var el = byPath(app.bodyEl, focusPath)
        if (el && typeof el.focus === 'function') {
          try {
            el.focus()
            if (caret && el.setSelectionRange) el.setSelectionRange(caret[0], caret[1])
          } catch (e) { }
        }
      }
    }
    app.render = render

    // ---------- 页面生命周期 ----------
    function createPage(opts, query) {
      var page = Object.assign({}, opts)
      page.data = clone(opts.data) || {}
      page.route = app.currentPath
      page.__options = opts
      page.setData = function (patch, cb) {
        if (patch) {
          Object.keys(patch).forEach(function (k) { setByPath(page.data, k, patch[k]) })
        }
        render()
        if (typeof cb === 'function') { try { cb() } catch (e) { console.error(e) } }
      }
      page.selectComponent = function () { return null }
      page.triggerEvent = function () { }
      page.createSelectorQuery = function () {
        return {
          select: function () { return this },
          selectAll: function () { return this },
          boundingClientRect: function (cb) { cb && cb({ left: 0, top: 0, width: 375, height: 0 }); return this },
          exec: function (cb) { cb && cb([]); return this }
        }
      }
      return page
    }

    function navigate(rawUrl, mode) {
      mode = mode || 'push'
      var parts = String(rawUrl || '').split('?')
      var path = parts[0].replace(/^\//, '').replace(/\.js$/, '')
      var query = {}
      ;(parts[1] || '').split('&').forEach(function (kv) {
        if (!kv) return
        var i = kv.indexOf('=')
        query[i < 0 ? kv : kv.slice(0, i)] = i < 0 ? '' : decodeURIComponent(kv.slice(i + 1))
      })
      if (mode === 'push' && app.currentPath) {
        app.pageStack.push({ path: app.currentPath, query: app.currentQuery, scrollTop: app.scrollEl ? app.scrollEl.scrollTop : 0 })
      }
      if (mode === 'replace' || mode === 'relaunch') app.pageStack = []
      loadPage(path, query)
      app.onRoute(path, query)
    }
    app.navigate = navigate
    app.back = function () {
      var prev = app.pageStack.pop()
      if (!prev) { ctx.log('warn', '已是第一个页面（真实小程序会退出小程序）', null); return }
      loadPage(prev.path, prev.query, prev.scrollTop)
      app.onRoute(prev.path, prev.query)
    }

    function loadPage(path, query, scrollTop) {
      if (app.page && typeof app.page.onUnload === 'function') {
        try { app.page.onUnload() } catch (e) { console.error(e) }
      }
      pendingPage = null
      app.currentPath = path
      app.currentQuery = query || {}
      var base = rootUrl + path
      loadModule(base + '.js')
      if (!pendingPage) {
        ctx.log('error', '页面未注册（Page() 未执行）：' + path, null)
        return
      }
      app.pageWxml = fetchTextSync(base + '.wxml')
      app.pageWxss = fetchTextSync(base + '.wxss')
      app.pageJson = (function () {
        var raw = fetchTextSync(base + '.json')
        try { return raw ? JSON.parse(raw) : {} } catch (e) { return {} }
      })()
      app.tpl = parseWxml(app.pageWxml)
      app.page = createPage(pendingPage, app.currentQuery)
      ctx.page = app.page
      render()
      try { app.page.onLoad && app.page.onLoad(app.currentQuery) } catch (e) { console.error(e) }
      try { app.page.onShow && app.page.onShow() } catch (e) { console.error(e) }
      try { app.page.onReady && app.page.onReady() } catch (e) { console.error(e) }
      if (scrollTop) app.scrollEl.scrollTop = scrollTop
      // 标题：页面 json 优先，其次 app.json 的 window
      var title = (app.pageJson.navigationBarTitleText) || (app.appJson.window && app.appJson.window.navigationBarTitleText) || ''
      app.onTitle(title)
      app.onTabbar(isTabPage(path) ? path : null)
    }
    app.loadPage = loadPage

    function isTabPage(path) {
      var list = (app.appJson.tabBar && app.appJson.tabBar.list) || []
      return list.some(function (t) { return t.pagePath === path })
    }
    app.isTabPage = isTabPage

    function reLaunch() {
      dropCache()
      Object.keys(modules).forEach(function (k) { delete modules[k] })
      modules = Object.create(null)
      app.appInstance = null
      boot()
    }
    app.reload = reLaunch

    // ---------- 覆盖层：toast / loading / modal / 图片预览 ----------
    function toast(o) {
      ensureShadow()
      var el = document.createElement('div')
      el.className = 'mini-toast'
      el.innerHTML = (o.icon === 'success' ? '✓ ' : o.icon === 'error' ? '✕ ' : '') + escapeHtml(o.title || '')
      app.overlayEl.appendChild(el)
      setTimeout(function () { el.remove() }, o.duration || 1800)
    }
    function showLoading(o) {
      ensureShadow()
      hideLoading()
      var el = document.createElement('div')
      el.className = 'mini-loading'
      el.textContent = (o && o.title) || '加载中'
      app.overlayEl.appendChild(el)
    }
    function hideLoading() {
      if (!app.overlayEl) return
      Array.prototype.forEach.call(app.overlayEl.querySelectorAll('.mini-loading'), function (n) { n.remove() })
    }
    function showModal(o) {
      return new Promise(function (resolve) {
        ensureShadow()
        var mask = document.createElement('div')
        mask.className = 'mini-modal'
        var box = document.createElement('div')
        box.className = 'mini-modal-box'
        box.innerHTML =
          (o.title ? '<div class="mini-modal-title">' + escapeHtml(o.title) + '</div>' : '') +
          '<div class="mini-modal-content">' + escapeHtml(o.content || '') + '</div>' +
          '<div class="mini-modal-btns"><div data-act="cancel">' + escapeHtml(o.cancelText || '取消') + '</div>' +
          '<div data-act="confirm">' + escapeHtml(o.confirmText || '确定') + '</div></div>'
        mask.appendChild(box)
        app.overlayEl.appendChild(mask)
        mask.addEventListener('click', function (ev) {
          var act = ev.target.getAttribute && ev.target.getAttribute('data-act')
          if (!act) return
          mask.remove()
          var res = { confirm: act === 'confirm', cancel: act === 'cancel' }
          if (act === 'confirm' && typeof o.success === 'function') o.success(res)
          if (act === 'cancel' && typeof o.fail === 'function') o.fail(res)
          if (typeof o.complete === 'function') o.complete(res)
          resolve(res)
        })
      })
    }
    function previewImage(o) {
      ensureShadow()
      var urls = o.urls || []
      var mask = document.createElement('div')
      mask.className = 'mini-viewer'
      var img = document.createElement('img')
      img.src = urls[o.current || 0] || PLACEHOLDER_IMG
      mask.appendChild(img)
      app.overlayEl.appendChild(mask)
      mask.addEventListener('click', function () { mask.remove() })
    }

    // ---------- wx API ----------
    function normalizeUrl(url) {
      // 小程序里是 http://localhost:8080/api/xxx，浏览器预览改为同源 /api/xxx（由预览服务代理）
      return String(url).replace(/^https?:\/\/[^/]+/, '')
    }
    function buildQuery(data) {
      var parts = []
      Object.keys(data || {}).forEach(function (k) {
        var v = data[k]
        if (v === undefined || v === null) return
        parts.push(encodeURIComponent(k) + '=' + encodeURIComponent(typeof v === 'object' ? JSON.stringify(v) : v))
      })
      return parts.join('&')
    }

    app.wx = {
      request: function (o) {
        var method = (o.method || 'GET').toUpperCase()
        var url = normalizeUrl(o.url)
        var body
        if (method === 'GET' || method === 'DELETE') {
          var qs = buildQuery(o.data)
          if (qs) url += (url.indexOf('?') < 0 ? '?' : '&') + qs
        } else {
          body = typeof o.data === 'string' ? o.data : JSON.stringify(o.data || {})
        }
        var started = Date.now()
        fetch(url, {
          method: method,
          headers: o.header || {},
          body: body
        }).then(function (res) {
          return res.text().then(function (text) {
            var data = text
            try { data = JSON.parse(text) } catch (e) { }
            ctx.log(res.status === 200 ? 'ok' : 'error', method + ' ' + url, res.status, Date.now() - started)
            o.success && o.success({ statusCode: res.status, data: data, header: {} })
            o.complete && o.complete({ statusCode: res.status, data: data })
          })
        }).catch(function (err) {
          ctx.log('error', method + ' ' + url + ' → ' + err.message, 0, Date.now() - started)
          o.fail && o.fail({ errMsg: 'request:fail ' + err.message })
          o.complete && o.complete({ errMsg: 'request:fail' })
        })
      },
      uploadFile: function (o) {
        var url = normalizeUrl(o.url)
        var started = Date.now()
        var form = new FormData()
        if (o.name) {
          var fake = new Blob([new Uint8Array([137, 80, 78, 71])], { type: 'image/png' })
          form.append(o.name, fake, 'preview.png')
        }
        Object.keys(o.formData || {}).forEach(function (k) { form.append(k, o.formData[k]) })
        fetch(url, { method: 'POST', headers: o.header || {}, body: form }).then(function (res) {
          return res.text().then(function (text) {
            ctx.log(res.status === 200 ? 'ok' : 'error', 'UPLOAD ' + url, res.status, Date.now() - started)
            o.success && o.success({ statusCode: res.status, data: text })
            o.complete && o.complete({ statusCode: res.status, data: text })
          })
        }).catch(function (err) {
          ctx.log('error', 'UPLOAD ' + url + ' → ' + err.message, 0, 0)
          o.fail && o.fail({ errMsg: 'uploadFile:fail ' + err.message })
        })
      },
      login: function (o) {
        ctx.log('info', 'wx.login（预览环境返回模拟 code）', null)
        setTimeout(function () { o && o.success && o.success({ code: 'PREVIEW_CODE_' + Date.now(), errMsg: 'login:ok' }) }, 30)
      },
      checkSession: function (o) { o && o.success && o.success({}) },
      getUserProfile: function (o) {
        var info = { nickName: '预览用户', avatarUrl: PLACEHOLDER_IMG, gender: 1 }
        o && o.success && o.success({ userInfo: info, rawData: '{}', signature: '' })
        return Promise.resolve({ userInfo: info })
      },
      getStorageSync: function (k) {
        var raw = localStorage.getItem(key(k))
        if (raw === null) return ''
        try { return JSON.parse(raw) } catch (e) { return raw }
      },
      setStorageSync: function (k, v) { localStorage.setItem(key(k), JSON.stringify(v)) },
      removeStorageSync: function (k) { localStorage.removeItem(key(k)) },
      clearStorageSync: function () {
        Object.keys(localStorage).forEach(function (k) {
          if (k.indexOf(STORE_PREFIX + appKey + ':') === 0) localStorage.removeItem(k)
        })
      },
      getStorageInfoSync: function () {
        var keys = Object.keys(localStorage).filter(function (k) { return k.indexOf(STORE_PREFIX + appKey + ':') === 0 })
          .map(function (k) { return k.split(':').slice(2).join(':') })
        return { keys: keys, currentSize: 0, limitSize: 10240 }
      },
      showToast: function (o) { toast(o || {}) },
      hideToast: function () {
        if (!app.overlayEl) return
        Array.prototype.forEach.call(app.overlayEl.querySelectorAll('.mini-toast'), function (n) { n.remove() })
      },
      showLoading: showLoading,
      hideLoading: hideLoading,
      showModal: showModal,
      showActionSheet: function (o) {
        var itemList = (o && o.itemList) || []
        return showModal({
          title: o && o.title,
          content: itemList.map(function (t, i) { return (i + 1) + '. ' + t }).join('\n'),
          confirmText: '知道了',
          showCancel: false
        })
      },
      previewImage: previewImage,
      navigateTo: function (o) { navigate(o.url, 'push') },
      redirectTo: function (o) { navigate(o.url, 'replace') },
      reLaunch: function (o) { navigate(o.url, 'relaunch') },
      switchTab: function (o) { navigate(o.url, 'tab') },
      navigateBack: function () { app.back() },
      setNavigationBarTitle: function (o) { app.onTitle((o && o.title) || '') },
      setNavigationBarColor: function () { },
      stopPullDownRefresh: function () { },
      startPullDownRefresh: function (o) { o && o.complete && o.complete({}) },
      pageScrollTo: function (o) { if (app.scrollEl) app.scrollEl.scrollTop = (o && o.scrollTop) || 0 },
      showTabBar: function () { }, hideTabBar: function () { },
      setClipboardData: function (o) {
        var text = (o && o.data) || ''
        if (navigator.clipboard) navigator.clipboard.writeText(text).catch(function () { })
        toast({ title: '已复制：' + text, icon: 'success' })
        o && o.success && o.success({})
      },
      makePhoneCall: function (o) {
        toast({ title: '模拟拨号：' + ((o && o.phoneNumber) || ''), icon: 'none' })
        o && o.success && o.success({})
      },
      requestPayment: function (o) {
        showModal({
          title: '模拟微信支付',
          content: '预览环境不唤起真实微信支付。\n\n订单号：' + ((o && o.package) ? '' : '') + '（点击确定视为支付成功）',
          confirmText: '支付成功',
          cancelText: '取消'
        }).then(function (res) {
          if (res.confirm) { o && o.success && o.success({ errMsg: 'requestPayment:ok' }) }
          else { o && o.fail && o.fail({ errMsg: 'requestPayment:fail cancel' }) }
        })
      },
      chooseMedia: function (o) {
        var input = document.createElement('input')
        input.type = 'file'
        input.accept = 'image/*'
        input.style.position = 'fixed'
        input.style.left = '-9999px'
        document.body.appendChild(input)
        input.addEventListener('change', function () {
          var file = input.files && input.files[0]
          if (!file) { o && o.fail && o.fail({ errMsg: 'chooseMedia:fail cancel' }); input.remove(); return }
          var url = URL.createObjectURL(file)
          var res = { tempFiles: [{ tempFilePath: url, size: file.size, fileType: 'image' }], type: 'image' }
          o && o.success && o.success(res)
          input.remove()
        })
        input.click()
      },
      chooseImage: function (o) { app.wx.chooseMedia(o) },
      getLocation: function (o) {
        o && o.success && o.success({ latitude: 29.13, longitude: 116.28, city: '上饶市', province: '江西省', address: '江西省上饶市鄱阳县' })
      },
      scanCode: function (o) {
        var code = global.prompt ? global.prompt('预览环境：请手工输入条码/运单号', '') : ''
        if (code) o && o.success && o.success({ result: code, scanType: 'CODE_128' })
        else o && o.fail && o.fail({ errMsg: 'scanCode:fail cancel' })
      },
      canIUse: function () { return false },
      nextTick: function (fn) { setTimeout(fn, 0) },
      getSystemInfoSync: function () {
        return {
          platform: 'devtools', brand: 'devtools', model: 'Browser Preview', system: 'Preview',
          windowWidth: 375, windowHeight: 600, screenWidth: 375, screenHeight: 667,
          pixelRatio: 2, statusBarHeight: 24, safeArea: { top: 24, bottom: 667 - 34, height: 667 - 58 }, SDKVersion: '3.0.0-preview'
        }
      },
      createSelectorQuery: function () {
        var chain = {
          select: function () { return chain },
          selectAll: function () { return chain },
          selectViewport: function () { return chain },
          boundingClientRect: function (cb) { cb && cb({ left: 0, top: 0, right: 375, bottom: 600, width: 375, height: 600 }); return chain },
          scrollOffset: function (cb) { cb && cb({ scrollTop: app.scrollEl ? app.scrollEl.scrollTop : 0, scrollLeft: 0 }); return chain },
          fields: function (f, cb) { cb && cb({}); return chain },
          exec: function (cb) { cb && cb([]); return chain }
        }
        return chain
      },
      createIntersectionObserver: function () { return { relativeTo: function () { return this }, relativeToViewport: function () { return this }, observe: function () { }, disconnect: function () { } } },
      onWindowResize: function () { }, offWindowResize: function () { },
      onAppShow: function () { }, onAppHide: function () { },
      getUpdateManager: function () { return { onCheckForUpdate: function () { }, onUpdateReady: function () { }, applyUpdate: function () { } } },
      setEnableDebug: function () { },
      reportAnalytics: function () { }
    }

    // ---------- 启动 ----------
    var savedRoute = null
    function boot(initialUrl) {
      app.appJson = (function () {
        try { return JSON.parse(fetchTextSync(rootUrl + 'app.json')) } catch (e) { return {} }
      })()
      app.appWxss = fetchTextSync(rootUrl + 'app.wxss')
      loadModule(rootUrl + 'app.js')
      var first = initialUrl || savedRoute || (app.appJson.pages && app.appJson.pages[0]) || 'pages/index/index'
      if (typeof first === 'string' && first.indexOf('pages/') !== 0) first = 'pages/' + first
      app.pageStack = []
      loadPage(String(first).replace(/^\//, '').split('?')[0], {})
      app.onRoute(app.currentPath, {})
    }
    app.boot = boot
    app.setInitial = function (url) { savedRoute = url }

    return app
  }

  global.MiniPreview = {
    createApp: createApp,
    storageKey: storageKey,
    STORE_PREFIX: STORE_PREFIX,
    PLACEHOLDER_IMG: PLACEHOLDER_IMG,
    transformWxss: transformWxss
  }
})(window)
