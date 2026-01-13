export interface ApiResponse<T> {
  data: T
  success: boolean
  message?: string
}

export interface ApiError {
  error: string
  code: string
  details?: any
}

export type ApiResult<T> = ApiResponse<T> | ApiError
