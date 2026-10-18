/**
 * 环境配置（渠道商端）
 */
const ENV = 'dev'

const CONFIG = {
  dev: {
    BASE_URL: 'http://localhost:8080/api'
  },
  test: {
    BASE_URL: 'https://test-api.xiegongzhu.com/api'
  },
  prod: {
    BASE_URL: 'https://api.xiegongzhu.com/api'
  }
}

module.exports = {
  ENV,
  BASE_URL: CONFIG[ENV].BASE_URL
}
