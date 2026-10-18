import axios from 'axios'

const request = axios.create({
  baseURL: import.meta.env.VITE_API_BASE || '/api',
  timeout: 20000
})

request.interceptors.response.use(
  (response) => {
    const body = response.data
    if (body && typeof body.code === 'number' && body.code !== 200) {
      return Promise.reject(new Error(body.message || '请求失败'))
    }
    return body?.data
  },
  (error) => Promise.reject(error)
)

export interface PortalProduct {
  id: number
  productName: string
  productNameEn?: string
  mainImage?: string
  images?: string
  detailHtml?: string
  detailHtmlEn?: string
  origin?: string
  retailPrice?: number
  sellMode?: string
  seoTitle?: string
  seoKeywords?: string
  seoDesc?: string
}

/**
 * 门户接口（与小程序同源数据，T23）
 */
export const portalApi = {
  site: () => request.get<never, Record<string, string>>('/portal/site'),
  nav: (platform = 'PC') => request.get<never, Array<Record<string, any>>>('/portal/nav', { params: { platform } }),
  i18n: (langCode: string) => request.get<never, Record<string, string>>(`/portal/i18n/${langCode}`),
  categories: () => request.get<never, Array<Record<string, any>>>('/portal/category/list'),
  productList: (params: Record<string, unknown> = {}) =>
    request.get<never, PortalProduct[]>('/portal/product/list', { params }),
  productDetail: (id: number | string) =>
    request.get<never, { product: PortalProduct; specs: Array<Record<string, any>>; skus: Array<Record<string, any>> }>(
      `/portal/product/${id}`
    ),
  articles: (categoryCode?: string) =>
    request.get<never, Array<Record<string, any>>>('/portal/article/list', { params: { categoryCode } }),
  article: (id: number | string) => request.get<never, Record<string, any>>(`/portal/article/${id}`),
  channelApply: (data: Record<string, unknown>) => request.post<never, number>('/portal/channel-apply', data)
}

export default request
