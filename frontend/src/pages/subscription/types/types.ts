export interface Category {
  guid: string
  name: string
}

export interface SubscriptionData {
  firstName: string
  lastName: string
  workEmail: string
  categoryGuids: string[]
}

export interface ValidationErrors {
  firstName: string
  lastName: string
  workEmail: string
  categories: string
}

export interface Validation {
  isValid: boolean
  errorMessage: string
}

export interface SubscriptionPayload {
  first_name: string
  last_name: string
  work_email: string
  category_guids: string[]
}

export interface SubscriptionListItem {
  work_email: string
  first_name: string
  last_name: string
  category_name: string
}

export interface SubscriptionListResponse {
  subscriptions: SubscriptionListItem[]
  next_cursor: number
  previous_cursor: number
  has_more: boolean
}

export type PaginationDirection = 'forward' | 'backward'

export interface SubscriptionQueryParams {
  limit?: number
  category_guids?: string[]
  pagination_id?: number
  pagination_direction?: PaginationDirection
}