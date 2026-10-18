import axios, { type AxiosInstance, type AxiosRequestConfig } from 'axios'
import { ElMessage } from 'element-plus'

/** 后端统一响应体：{ code, message, data } */
export interface R<T> {
  code: number
  message: string
  data: T
}

export interface PageResult<T> {
  records: T[]
  total: number
  current: number
  size: number
}

const TOKEN_KEY = 'crab_admin_token'

export const getToken = () => localStorage.getItem(TOKEN_KEY) || ''
export const setToken = (token: string) => localStorage.setItem(TOKEN_KEY, token)
export const clearToken = () => localStorage.removeItem(TOKEN_KEY)

const request: AxiosInstance = axios.create({
  baseURL: import.meta.env.VITE_API_BASE || '/api',
  timeout: 30000
})

request.interceptors.request.use((config) => {
  const token = getToken()
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

request.interceptors.response.use(
  (response) => {
    const body = response.data as R<unknown>
    if (body && typeof body.code === 'number' && body.code !== 200) {
      ElMessage.error(body.message || '操作失败')
      if (body.code === 401) {
        clearToken()
        window.location.hash = '#/login'
      }
      return Promise.reject(new Error(body.message))
    }
    // 剥离统一响应体外层：调用方直接拿到 data
    // （后端约定：HTTP 恒为 200，业务码在 body.code；勿改成 return body）
    return body?.data as never
  },
  (error) => {
    const message = error?.response?.data?.message || error.message || '网络异常，请稍后重试'
    ElMessage.error(message)
    return Promise.reject(error)
  }
)

/** 统一请求方法（返回 data 体） */
export function http<T>(config: AxiosRequestConfig): Promise<T> {
  // 响应拦截器已剥离 { code, message, data } 外层，仅返回 data
  return request.request(config) as unknown as Promise<T>
}

export default request
