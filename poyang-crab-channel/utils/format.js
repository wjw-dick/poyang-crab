/** 通用格式化工具（渠道商端） */

function money(value, digits = 2) {
  const num = Number(value)
  if (isNaN(num)) return '0.00'
  return num.toFixed(digits)
}

function splitPrice(value) {
  const text = money(value)
  const arr = text.split('.')
  return { int: arr[0], decimal: arr[1] || '00' }
}

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

/** 报单审核状态（t_channel_order.audit_status） */
const AUDIT_STATUS_TEXT = {
  PENDING: '待审核',
  APPROVED: '已通过',
  REJECTED: '已驳回'
}

/** 佣金结算状态（t_commission.settle_status） */
const SETTLE_STATUS_TEXT = {
  PENDING: '待结算',
  SETTLED: '已结算'
}

/** 结算单状态（t_settlement.status） */
const SETTLEMENT_STATUS_TEXT = {
  DRAFT: '待确认',
  CONFIRMED: '已确认',
  PAID: '已打款'
}

/** 渠道商状态（t_channel.status） */
const CHANNEL_STATUS_TEXT = {
  NORMAL: '正常',
  FROZEN: '冻结',
  PENDING: '待审核',
  DISABLED: '停用'
}

/** 批发订单状态（与 sql/03_order.sql + 99_init_data.sql 字典一致） */
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

function textOf(dict, key) {
  return dict[key] || key || ''
}

function percent(value) {
  const num = Number(value)
  if (isNaN(num)) return '0%'
  return num + '%'
}

module.exports = {
  money,
  splitPrice,
  formatDate,
  textOf,
  percent,
  AUDIT_STATUS_TEXT,
  SETTLE_STATUS_TEXT,
  SETTLEMENT_STATUS_TEXT,
  CHANNEL_STATUS_TEXT,
  ORDER_STATUS_TEXT
}
