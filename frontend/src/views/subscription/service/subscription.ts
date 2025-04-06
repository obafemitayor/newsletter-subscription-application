import axios from 'axios'
import type { SubscriptionPayload } from '../types/types'
import { BASE_URL } from '../helpers/constants'

export const createSubscriptionForCustomer = async (subscription: SubscriptionPayload): Promise<void> => {
  await axios.post(`${BASE_URL}/subscriptions`, subscription)
} 