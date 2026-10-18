/* eslint-disable */
/**
 * 预览页 UI：把「小程序运行时」装进一个手机壳里（导航栏 / tabBar / 页面切换 / 请求日志）。
 * 被 index.html（双端并排）与 single.html（单端放大）共用。
 */
;(function (global) {
  'use strict'

  var APPS = [
    {
      key: 'miniapp',
      dir: 'poyang-crab-miniapp',
      name: 'C 端小程序',
      sub: '商城 · 购物车 · 订单 · 会员',
      tokenKey: 'CRAB_TOKEN',
      userKey: 'CRAB_USER',
      profileUrl: '/api/member/profile',
      // 详情类页面必须带参数才能看到内容，这里给出演示数据的默认参数（真实小程序由上一页跳转时携带）
      defaultQuery: {
        'pages/product/detail': 'id=1',
        'pages/article/index': 'id=1',
        'pages/order/detail': 'orderNo=DD202610100001',
        'pages/logistics/index': 'orderNo=DD202610100001',
        'pages/review/index': 'orderNo=DD202610100001'
      },
      logins: [
        { id: 0, label: '未登录（仅公开页有数据）' },
        { id: 1, label: '会员1 · 鄱阳湖畔的吃货（GOLD）' },
        { id: 2, label: '会员2 · 蟹老板' },
        { id: 3, label: '会员3 · 老张张三' }
      ]
    },
    {
      key: 'channel',
      dir: 'poyang-crab-channel',
      name: '渠道商端小程序',
      sub: '工作台 · 渠道价 · 报单 · 佣金结算',
      tokenKey: 'CHANNEL_TOKEN',
      userKey: 'CHANNEL_INFO',
      profileUrl: '/api/channel/biz/profile',
      defaultQuery: {},
      logins: [
        { id: 0, label: '未登录（会跳登录页）' },
        { id: 1, label: '渠道1 · 南昌蟹逅商贸有限公司' },
        { id: 2, label: '渠道2 · 九江鲜生优选' }
      ]
    }
  ]

  function el(tag, cls, html) {
    var node = document.createElement(tag)
    if (cls) node.className = cls
    if (html != null) node.innerHTML = html
    return node
  }

  function shortPath(p) {
    var seg = String(p).split('/')
    return seg.slice(-2).join('/')
  }

  // ============================ 单个设备（手机壳） ============================
  function createDevice(config, opts) {
    opts = opts || {}
    var device = {
      config: config,
      log: [],
      app: null,
      appJson: {},
      currentPath: '',
      loginId: 1
    }

    var root = el('div', 'device')
    root.id = 'device-' + config.key

    // ---- 头部 ----
    var head = el('div', 'device-head')
    head.appendChild(el('div', 'device-title', config.name))
    head.appendChild(el('div', 'device-sub', config.dir + ' · ' + config.sub))
    root.appendChild(head)

    // ---- 工具条 ----
    var bar = el('div', 'device-bar')
    var loginSel = document.createElement('select')
    loginSel.className = 'mini-select'
    config.logins.forEach(function (l) {
      var o = document.createElement('option')
      o.value = String(l.id)
      o.textContent = '登录态：' + l.label
      loginSel.appendChild(o)
    })
    var pageSel = document.createElement('select')
    pageSel.className = 'mini-select'
    loginSel.value = String(device.loginId)
    var btnReload = el('button', 'mini-btn', '重新加载')
    var btnClear = el('button', 'mini-btn', '清空本地缓存')
    var btnPopout = el('a', 'mini-btn', '独立窗口')
    btnPopout.href = 'single.html?app=' + config.key
    btnPopout.target = '_blank'
    bar.appendChild(loginSel)
    bar.appendChild(pageSel)
    bar.appendChild(btnReload)
    bar.appendChild(btnClear)
    bar.appendChild(btnPopout)
    root.appendChild(bar)

    // ---- 手机壳 ----
    var phone = el('div', 'phone')
    var status = el('div', 'phone-status')
    status.innerHTML = '<span>9:41</span><span>鄱阳湖 · 5G · 100%</span>'
    var nav = el('div', 'phone-nav')
    var back = el('span', 'phone-back', '‹')
    var title = el('span', 'phone-title')
    nav.appendChild(back)
    nav.appendChild(title)
    var viewport = el('div', 'phone-viewport')
    var tabbar = el('div', 'phone-tabbar')
    phone.appendChild(status)
    phone.appendChild(nav)
    phone.appendChild(viewport)
    phone.appendChild(tabbar)
    root.appendChild(phone)

    // ---- 页面胶囊 ----
    var pages = el('div', 'device-pages')
    root.appendChild(pages)

    // ---- 请求日志 ----
    var logWrap = el('details', 'device-log')
    var summary = el('summary', '', '请求日志 <span class="log-count">0</span>')
    var logBody = el('div', 'log-body')
    logWrap.appendChild(summary)
    logWrap.appendChild(logBody)
    root.appendChild(logWrap)

    device.root = root
    device.viewport = viewport
    device.tabbar = tabbar
    device.nav = nav
    device.back = back
    device.titleEl = title
    device.logBody = logBody
    device.logCount = summary.querySelector('.log-count')
    device.pageSel = pageSel
    device.loginSel = loginSel

    // ---- 日志 ----
    function pushLog(level, text, status, ms) {
      device.log.push({ level: level, text: text, status: status, ms: ms, at: new Date() })
      if (device.log.length > 60) device.log.shift()
      renderLog()
    }
    function renderLog() {
      device.logCount.textContent = String(device.log.length)
      logBody.innerHTML = ''
      device.log.slice().reverse().forEach(function (item) {
        var row = el('div', 'log-row ' + item.level)
        var t = item.at.toTimeString().slice(0, 8)
        var st = item.status ? ('[' + item.status + '] ') : ''
        row.textContent = t + ' ' + st + item.text + (item.ms ? '  ' + item.ms + 'ms' : '')
        logBody.appendChild(row)
      })
    }
    device.pushLog = pushLog

    // ---- 启动 / 重启 ----
    function freshHost() {
      viewport.innerHTML = ''
      var host = el('div', 'mini-host')
      viewport.appendChild(host)
      return host
    }

    function boot(initialPage) {
      var host = freshHost()
      device.app = global.MiniPreview.createApp({
        appKey: config.key,
        rootUrl: '/' + config.dir,
        host: host,
        log: pushLog,
        onTitle: function (t) {
          title.textContent = t || ''
        },
        onTabbar: function (activePath) {
          renderTabbar(activePath)
        },
        onRoute: function (path, query) {
          device.currentPath = path
          pageSel.value = path
          highlightChips(path)
          title.textContent = title.textContent // 保持
          back.style.visibility = device.app && device.app.pageStack.length ? 'visible' : 'hidden'
        }
      })
      try {
        device.app.boot(initialPage || config.logins.startPage)
      } catch (e) {
        pushLog('error', '启动失败：' + e.message, 0)
        console.error(e)
      }
    }

    function renderTabbar(activePath) {
      var list = (device.appJson.tabBar && device.appJson.tabBar.list) || []
      tabbar.innerHTML = ''
      if (!list.length || !activePath) {
        tabbar.style.display = 'none'
        return
      }
      tabbar.style.display = 'flex'
      var tb = device.appJson.tabBar
      tabbar.style.background = tb.backgroundColor || '#fff'
      tabbar.style.borderTop = '1px solid #E5E5E5'
      list.forEach(function (item) {
        var tab = el('div', 'tab-item')
        tab.textContent = item.text
        var active = item.pagePath === activePath
        tab.style.color = active ? (tb.selectedColor || '#0B3D91') : (tb.color || '#8C8C8C')
        if (active) tab.classList.add('active')
        tab.addEventListener('click', function () {
          if (device.app) device.app.navigate('/' + item.pagePath, 'tab')
        })
        tabbar.appendChild(tab)
      })
    }

    function highlightChips(path) {
      Array.prototype.forEach.call(pages.querySelectorAll('.chip'), function (chip) {
        chip.classList.toggle('active', chip.getAttribute('data-path') === path)
      })
    }

    // 详情页带上演示参数，避免「预览时一片空白」
    function pageUrl(p) {
      var q = (config.defaultQuery || {})[p]
      return '/' + p + (q ? '?' + q : '')
    }
    device.pageUrl = pageUrl

    function renderPageList() {
      pages.innerHTML = ''
      var list = device.appJson.pages || []
      var tabPaths = ((device.appJson.tabBar && device.appJson.tabBar.list) || []).map(function (t) { return t.pagePath })
      ;(device.appJson.pages || []).forEach(function (p) {
        var chip = el('button', 'chip', shortPath(p) + (tabPaths.indexOf(p) >= 0 ? ' <b>tab</b>' : ''))
        chip.setAttribute('data-path', p)
        chip.title = p
        chip.addEventListener('click', function () {
          if (device.app) device.app.navigate(pageUrl(p), device.app.isTabPage(p) ? 'tab' : 'push')
        })
        pages.appendChild(chip)
      })
      pageSel.innerHTML = ''
      list.forEach(function (p) {
        var o = document.createElement('option')
        o.value = p
        o.textContent = shortPath(p) + (tabPaths.indexOf(p) >= 0 ? '（tab）' : '')
        pageSel.appendChild(o)
      })
    }

    // ---- 交互 ----
    pageSel.addEventListener('change', function () {
      var p = pageSel.value
      if (device.app) device.app.navigate(pageUrl(p), device.app.isTabPage(p) ? 'tab' : 'push')
    })
    loginSel.addEventListener('change', function () {
      device.loginId = Number(loginSel.value)
      applyLogin(device, config, Number(loginSel.value)).then(function () {
        boot(device.currentPath || (device.appJson.pages || [])[0])
      })
    })
    btnReload.addEventListener('click', function () {
      boot(device.currentPath || (device.appJson.pages || [])[0])
    })
    btnClear.addEventListener('click', function () {
      Object.keys(localStorage).forEach(function (k) {
        if (k.indexOf(global.MiniPreview.STORE_PREFIX + config.key + ':') === 0) localStorage.removeItem(k)
      })
      loginSel.value = '0'
      device.loginId = 0
      boot((device.appJson.pages || [])[0])
    })
    back.addEventListener('click', function () {
      if (device.app) device.app.back()
    })

    device.boot = boot
    device.renderPageList = function () { renderPageList() }

    // ---- 初始化：读 app.json（页面清单/tabBar/导航栏配色）----
    device.ready = fetch('/' + config.dir + '/app.json', { cache: 'no-store' })
      .then(function (r) { return r.json() })
      .then(function (json) {
        device.appJson = json || {}
        renderPageList()
        var win = device.appJson.window || {}
        nav.style.background = win.navigationBarBackgroundColor || '#0B3D91'
        nav.style.color = win.navigationBarTextStyle === 'black' ? '#1F1F1F' : '#fff'
        status.style.background = win.navigationBarBackgroundColor || '#0B3D91'
        back.style.color = nav.style.color
      })
      .catch(function (e) {
        pushLog('error', '读取 app.json 失败：' + e.message, 0)
      })

    return device
  }

  // ============================ 登录态注入 ============================
  function applyLogin(device, config, id) {
    var tokenUrl = '/preview/token?app=' + config.key + '&id=' + id
    return fetch(tokenUrl, { cache: 'no-store' })
      .then(function (r) { return r.json() })
      .then(function (data) {
        var tokenKey = global.MiniPreview.storageKey(config.key, config.tokenKey)
        var userKey = global.MiniPreview.storageKey(config.key, config.userKey)
        if (!data.token) {
          localStorage.removeItem(tokenKey)
          localStorage.removeItem(userKey)
          device.pushLog('info', '已切换为「未登录」', null)
          return null
        }
        localStorage.setItem(tokenKey, JSON.stringify(data.token))
        // 拉取档案写入本地（渠道端 requireChannel() 需要 CHANNEL_INFO）
        return fetch(config.profileUrl, {
          headers: { Authorization: 'Bearer ' + data.token },
          cache: 'no-store'
        }).then(function (r) { return r.json() }).then(function (body) {
          if (body && body.code === 200) {
            localStorage.setItem(userKey, JSON.stringify(body.data))
            device.pushLog('info', '已注入预览登录态：' + (body.data.channelName || body.data.nickname || ('id=' + data.id)), 200)
          } else {
            device.pushLog('error', '预览令牌已注入，但拉取档案失败：' + ((body && body.message) || ''), body && body.code)
          }
        })
      })
      .catch(function (e) {
        device.pushLog('error', '注入登录态失败：' + e.message, 0)
      })
  }

  // ============================ 页面挂载 ============================
  function mount(container, keys, opts) {
    opts = opts || {}
    var devices = []
    var wrap = el('div', 'stage')
    container.appendChild(wrap)
    keys.forEach(function (key) {
      var config = APPS.filter(function (a) { return a.key === key })[0]
      if (!config) return
      var device = createDevice(config, opts)
      devices.push(device)
      wrap.appendChild(device.root)
    })
    // 全部就绪后启动（顺序：注入默认登录态 → boot）
    global.__previewDevices = devices
    return Promise.all(devices.map(function (d) { return d.ready })).then(function () {
      return devices.reduce(function (chain, device) {
        return chain.then(function () {
          return applyLogin(device, device.config, device.loginId).then(function () {
            device.boot((device.appJson.pages || [])[0])
          })
        })
      }, Promise.resolve())
    }).then(function () {
      return devices
    })
  }

  global.MiniPreviewUI = { mount: mount, APPS: APPS }
})(window)
