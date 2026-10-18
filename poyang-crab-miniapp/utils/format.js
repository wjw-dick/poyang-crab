/** 通用格式化工具 */

/** 金额分转元显示（后端金额单位为元，此处仅做兜底格式化） */
function money(value, digits = 2) {
  const num = Number(value)
  if (isNaN(num)) return '0.00'
  return num.toFixed(digits)
}

/** 拆分整数/小数，便于大号价格排版 */
function splitPrice(value) {
  const text = money(value)
  const arr = text.split('.')
  return { int: arr[0], decimal: arr[1] || '00' }
}

/** 时间戳/字符串统一格式化，兼容 iOS 对 'YYYY-MM-DD HH:mm:ss' 的解析差异 */
function formatDate(value, pattern = 'YYYY-MM-DD HH:mm') {
  if (!value) return ''
  const date = value instanceof Date ? value : new Date(String(value).replace(/-/g, '/'))
  if (isNaN(date.getTime())) return String(value)
  const pad = (n) => (n < 10 ? '0' + n : '' + n)
  return pattern
    .replace('YYYY', date.getFullYear())
    .replace('MM', pad(date.getMonth() + 1))
    .replace('DD', pad(date.getDate()))
    .replace('HH', pad(date.getHours()))
    .replace('mm', pad(date.getMinutes()))
    .replace('ss', pad(date.getSeconds()))
}

/** 订单状态文案，与 sql/03_order.sql + 99_init_data.sql 字典保持一致 */
const ORDER_STATUS_TEXT = {
  UNPAID: '待支付',
  PAID: '已支付',
  SORTING: '分拣中',
  PACKED: '已打包',
  SHIPPED: '已发货',
  RECEIVED: '已收货',
  COMPLETED: '已完成',
  CANCELLED: '已取消',
  REFUNDING: '退款中',
  REFUNDED: '已退款'
}

function orderStatusText(status) {
  return ORDER_STATUS_TEXT[status] || status || ''
}

/** 脱敏手机号 */
function maskPhone(phone) {
  if (!phone || phone.length < 7) return phone || ''
  return phone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2')
}

/** 公母文案（湖蟹售卖关键属性） */
function genderText(gender) {
  if (gender === 'MALE') return '公蟹'
  if (gender === 'FEMALE') return '母蟹'
  if (gender === 'MIXED') return '公母搭配'
  return gender || ''
}

module.exports = { money, splitPrice, formatDate, orderStatusText, ORDER_STATUS_TEXT, maskPhone, genderText }
