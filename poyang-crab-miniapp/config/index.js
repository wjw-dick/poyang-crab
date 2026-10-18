/**
 * 环境配置
 * 小程序不支持 .env，构建期通过微信开发者工具「详情-本地设置」或 CI 替换本文件。
 */
const ENV = 'dev'

const CONFIG = {
  dev: {
    // 本地联调：微信开发者工具需勾选「不校验合法域名」
    BASE_URL: 'http://localhost:8080/api',
    WS_URL: 'ws://localhost:8080/api/ws'
  },
  test: {
    BASE_URL: 'https://test-api.xiegongzhu.com/api',
    WS_URL: 'wss://test-api.xiegongzhu.com/api/ws'
  },
  prod: {
    BASE_URL: 'https://api.xiegongzhu.com/api',
    WS_URL: 'wss://api.xiegongzhu.com/api/ws'
  }
}

module.exports = {
  ENV,
  BASE_URL: CONFIG[ENV].BASE_URL,
  WS_URL: CONFIG[ENV].WS_URL
}
