import axios from 'axios';
import type { Category } from '../types/types';
import { BASE_URL } from '../helpers/constants';

export const fetchCategories = async (): Promise<Category[]> => {
  const { data } = await axios.get(`${BASE_URL}/categories`);
  return data.categories;
};