<template>
  <div class="subscription-list">
    <div class="filter-section">
      <div class="categories-list">
        <h3>{{ $t('subscriptionList.title') }}</h3>
        <div class="checkbox-group">
          <div v-for="category in categories" :key="category.guid" class="category-checkbox">
            <label>
              <input :aria-label="$t('subscriptionList.filter.checkbox', { category: category.name })" type="checkbox" v-model="selectedCategories" :value="category.guid">
              <span class="checkbox-label">{{ category.name }}</span>
            </label>
          </div>
        </div>
        <button v-if="categories.length > 0 && subscriptions.length > 0" class="filter-button" @click="filterSubscriptions">{{ $t('subscriptionList.filter.button') }}</button>
      </div>
    </div>

    <div class="table-section">
      <table v-if="subscriptions.length">
        <thead>
          <tr>
            <th>{{ $t('subscriptionList.table.email') }}</th>
            <th>{{ $t('subscriptionList.table.firstName') }}</th>
            <th>{{ $t('subscriptionList.table.lastName') }}</th>
            <th>{{ $t('subscriptionList.table.category') }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(subscription, index) in subscriptions" :key="index">
            <td>{{ subscription.work_email }}</td>
            <td>{{ subscription.first_name }}</td>
            <td>{{ subscription.last_name }}</td>
            <td>{{ subscription.category_name }}</td>
          </tr>
        </tbody>
      </table>
      <div v-else class="no-data">{{ $t('subscriptionList.table.noData') }}</div>
    </div>

    <div class="pagination-buttons">
      <button 
        v-if="showLoadPreviousButton" 
        class="pagination-button" 
        @click="paginate('backward')"
      >
        {{ $t('subscriptionList.pagination.loadPrevious') }}
      </button>
      <button 
        v-if="showLoadNextButton" 
        class="pagination-button" 
        @click="paginate('forward')"
      >
        {{ $t('subscriptionList.pagination.loadNext') }}
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useI18n } from 'vue-i18n'
import { fetchCategories } from '../service/category'
import { getSubscriptions } from '../service/subscription'
import { Category, SubscriptionListItem, SubscriptionQueryParams, PaginationDirection, SubscriptionListResponse } from '../types/types'

const { t } = useI18n()
const categories = ref<Category[]>([])
const subscriptions = ref<SubscriptionListItem[]>([])
const selectedCategories = ref<string[]>([])
const hasMore = ref(true)
const previousCursor = ref<number | null>(null)
const nextCursor = ref<number | null>(null)
const paginationDirection = ref<PaginationDirection>('forward')
const limit = 10
const showLoadPreviousButton = ref(false);
const showLoadNextButton = ref(false);
const isFirstPage = ref(true);

const buildQueryParams =  () : SubscriptionQueryParams => {
  const params: SubscriptionQueryParams = { limit, pagination_direction: paginationDirection.value };

  if (selectedCategories.value.length > 0) {
    params.category_guids = selectedCategories.value
  }

  if (!isFirstPage.value && paginationDirection.value === 'forward' && nextCursor.value !== null) {
    params.pagination_id = nextCursor.value
  }

  if (!isFirstPage.value && paginationDirection.value === 'backward' && previousCursor.value !== null) {
    params.pagination_id = previousCursor.value
  }
  
  return params
}

const setPaginationButtons = () => {
  if(paginationDirection.value === 'forward') {
    showLoadPreviousButton.value = isFirstPage.value ? false : true
    showLoadNextButton.value = hasMore.value;
    return;
  }
  showLoadPreviousButton.value = hasMore.value
  showLoadNextButton.value = true
}

const getCategories = async () => {
  try {
    return await fetchCategories();
  } catch (error) {
    throw new Error(t('alerts.categories.error'));
  }
}

const getSubscriptionList = async (params: SubscriptionQueryParams) => {
  try {
    return await getSubscriptions(params)
  } catch (error) {
    throw new Error(t('alerts.subscriptionList.error'));
  }
}

const setCategoryData = async (response: Category[]) => {
  categories.value = response
}

const setSubscriptionData = async (response: SubscriptionListResponse) => {
  subscriptions.value = response.subscriptions
  previousCursor.value = response.previous_cursor
  nextCursor.value = response.next_cursor
  hasMore.value = response.has_more
  setPaginationButtons()
}

const filterSubscriptions = async () => {
  isFirstPage.value = true;
  paginationDirection.value = 'forward';
  const response = await getSubscriptionList(buildQueryParams());
  setSubscriptionData(response)
}

const paginate = async (direction: PaginationDirection) => {
  paginationDirection.value = direction
  isFirstPage.value = false;
  const response = await getSubscriptionList(buildQueryParams());
  setSubscriptionData(response)
}

onMounted(async () => {
  try {
    const [categories, subscriptions] = await Promise.all([getCategories(), getSubscriptionList(buildQueryParams())]);
    setCategoryData(categories)
    setSubscriptionData(subscriptions)
  } catch (error: unknown) {
    if (error instanceof Error) {
      alert(error.message);
    }
  }
});

</script>

<style scoped lang="scss">
@use "sass:color";

.subscription-list {
  padding: 20px;

  .filter-section {
    margin-bottom: 20px;
    width: 100%;

    .categories-list {
      width: 100%;
      margin-bottom: 20px;
      display: flex;
      flex-direction: column;

      h3 {
        margin-bottom: 15px;
        text-align: left;
      }

      .checkbox-group {
        display: flex;
        flex-direction: row;
        gap: 20px;
        margin-bottom: 15px;
        flex-wrap: wrap;
        justify-content: flex-start;

        .category-checkbox {
          label {
            display: flex;
            align-items: center;
            gap: 8px;
            cursor: pointer;

            input[type="checkbox"] {
              margin: 0;
            }

            .checkbox-label {
              font-size: 14px;
            }
          }
        }
      }

      .filter-button {
        padding: 10px 20px;
        background-color: #4a90e2;
        color: white;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        font-size: 14px;
        font-weight: 500;
        align-self: flex-start;

        &:hover {
          background-color: color.adjust(#4a90e2, $lightness: -10%);
        }
      }
    }
  }

  .table-section {
    margin-top: 20px;
    overflow-x: auto;

    table {
      width: 100%;
      border-collapse: collapse;
      min-width: 600px;

      th,
      td {
        padding: 12px;
        text-align: left;
        border-bottom: 1px solid #ddd;
      }

      th {
        background-color: #f5f5f5;
        font-weight: 600;
      }

      tbody tr:hover {
        background-color: #f9f9f9;
      }
    }
  }

  .pagination-buttons {
    display: flex;
    justify-content: flex-end;
    gap: 10px;
    margin-top: 20px;

    .pagination-button {
      padding: 10px 20px;
      background-color: #4a90e2;
      color: white;
      border: none;
      border-radius: 4px;
      cursor: pointer;

      &:hover {
        background-color: color.adjust(#4a90e2, $lightness: -10%);
      }

      &:disabled {
        background-color: #ccc;
        cursor: not-allowed;
      }
    }
  }

  .no-data {
    text-align: center;
    padding: 20px;
    color: #666;
  }
}
</style>
