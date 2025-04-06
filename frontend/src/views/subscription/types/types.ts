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