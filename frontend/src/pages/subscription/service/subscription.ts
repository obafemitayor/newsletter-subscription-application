import axios from 'axios';
import type { SubscriptionPayload, SubscriptionListResponse, SubscriptionQueryParams } from '../types/types';
import { BASE_URL } from '../helpers/constants';

export const createSubscriptionForCustomer = async (subscription: SubscriptionPayload): Promise<void> => {
  await axios.post(`${BASE_URL}/subscriptions`, subscription);
};

export const getSubscriptions = async (params?: SubscriptionQueryParams): Promise<SubscriptionListResponse> => {
  const { data } = await axios.get(`${BASE_URL}/subscriptions`, { params });
  return data;
};