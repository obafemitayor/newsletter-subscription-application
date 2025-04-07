import { render, screen, waitFor, fireEvent } from '@testing-library/vue';
import i18n from './utils/utils';
import SubscriptionList from '../pages/subscription/components/SubscriptionList.vue';
import axios from 'axios';
import type { Category, SubscriptionQueryParams, SubscriptionListResponse } from '../pages/subscription/types/types';
import { page1Data, page2Data, page3Data } from './utils/subscription-list-mock-data';
import { mockCategories } from './utils/categories-mock-data';
import { mockSubscriptions } from './utils/subscription-list-mock-data';

const realAxiosGet = axios.get;
jest.mock('axios');
const mockedAxios = axios as jest.Mocked<typeof axios>;
const alertMock = jest.spyOn(window, 'alert').mockImplementation();
const BASE_URL = 'http://localhost:3000/v1';

const initGetCategoriesMock = (status: number, categories: Category[] | null, error: Error | null = null) => {
  mockedAxios.get.mockImplementationOnce((url: string, config) => {
    if (url === `${BASE_URL}/categories`) {
      return status === 200 ? Promise.resolve({ data: { categories } }) : Promise.reject(error);
    }
    return realAxiosGet(url, config);
  });
};

const initGetSubscriptionsMock = (
  status: number, 
  queryParams: SubscriptionQueryParams | null, 
  response: SubscriptionListResponse,
  error: Error | null = null
) => {
  mockedAxios.get.mockImplementationOnce((url: string, config) => {
    if (url.startsWith(`${BASE_URL}/subscriptions`) && JSON.stringify(config?.params) === JSON.stringify(queryParams)) {
      return status === 200 
        ? Promise.resolve({ data: response })
        : Promise.reject(error || new Error('Server error'));
    }
    return realAxiosGet(url, config);
  });
};

const renderComponent = () => {
  return render(SubscriptionList, {
    global: {
      plugins: [i18n]
    }
  });
};

describe('SubscriptionList Component', () => {
  beforeEach(() => {
    mockedAxios.get.mockReset();
    alertMock.mockClear();
  });

  afterAll(() => {
    mockedAxios.get.mockReset();
    alertMock.mockRestore();
  });

  it('should load successfully when categories and subscriptions are fetched successfully', async () => {
    initGetCategoriesMock(200, mockCategories);
    initGetSubscriptionsMock(200, 
      { limit: 10, 
        pagination_direction: 'forward' 
      },
      {
        subscriptions: mockSubscriptions,
        next_cursor: 3,
        previous_cursor: 1,
        has_more: false
      });
    renderComponent();

    await waitFor(() => {
      expect(screen.queryAllByText('Product updates')).toHaveLength(2);
      expect(screen.queryAllByText('Articles and market insights')).toHaveLength(2);
      expect(screen.queryAllByText('Case studies')).toHaveLength(1);

      expect(screen.getByText('john@example.com')).toBeInTheDocument();
      expect(screen.getByText('jane@example.com')).toBeInTheDocument();

      expect(screen.queryByText('Previous')).not.toBeInTheDocument();
      expect(screen.queryByText('Next')).not.toBeInTheDocument();
    });
  });

  it('should show error when categories fetching fails', async () => {
    initGetCategoriesMock(500, null, new Error('Failed to fetch'));
    initGetSubscriptionsMock(200, 
      { limit: 10, 
        pagination_direction: 'forward' 
      },
      {
        subscriptions: mockSubscriptions,
        next_cursor: 3,
        previous_cursor: 1,
        has_more: false
      });
    
    renderComponent();

    await waitFor(() => {
      expect(alertMock).toHaveBeenCalledWith('Failed to fetch categories, please try again');
      expect(alertMock).not.toHaveBeenCalledWith('Failed to fetch subscriptions');
      expect(screen.getByText('No subscriptions found')).toBeInTheDocument();
      expect(screen.queryByText('Product updates')).not.toBeInTheDocument();
      expect(screen.queryByText('Articles and market insights')).not.toBeInTheDocument();
      expect(screen.queryByText('Case studies')).not.toBeInTheDocument();
      expect(screen.queryByText('john@example.com')).not.toBeInTheDocument();
      expect(screen.queryByText('jane@example.com')).not.toBeInTheDocument();
      expect(screen.queryByText('Previous')).not.toBeInTheDocument();
      expect(screen.queryByText('Next')).not.toBeInTheDocument();
      expect(screen.queryByText('Filter subscriptions')).not.toBeInTheDocument();
      expect(screen.getByText('No subscriptions found')).toBeInTheDocument();
    });
  });

  it('should show error when subscriptions fetching fails', async () => {
    initGetCategoriesMock(200, mockCategories);
    initGetSubscriptionsMock(500, 
      { limit: 10, 
        pagination_direction: 'forward' 
      },
      {
        subscriptions: mockSubscriptions,
        next_cursor: 3,
        previous_cursor: 1,
        has_more: false
      },
      new Error('Failed to fetch subscriptions'));
    renderComponent();

    await waitFor(() => {
      expect(alertMock).toHaveBeenCalledWith('Failed to fetch subscriptions');
      expect(alertMock).not.toHaveBeenCalledWith('Failed to fetch categories');
      expect(screen.getByText('No subscriptions found')).toBeInTheDocument();
      expect(screen.queryByText('Product updates')).not.toBeInTheDocument();
      expect(screen.queryByText('Articles and market insights')).not.toBeInTheDocument();
      expect(screen.queryByText('Case studies')).not.toBeInTheDocument();
      expect(screen.queryByText('john@example.com')).not.toBeInTheDocument();
      expect(screen.queryByText('jane@example.com')).not.toBeInTheDocument();
      expect(screen.queryByText('Previous')).not.toBeInTheDocument();
      expect(screen.queryByText('Next')).not.toBeInTheDocument();
      expect(screen.queryByText('Filter subscriptions')).not.toBeInTheDocument();
    });
  });

  it('should filter subscriptions when one category is selected', async () => {
    initGetCategoriesMock(200, mockCategories);
    initGetSubscriptionsMock(200, 
      { limit: 10, pagination_direction: 'forward' },
      {
        subscriptions: mockSubscriptions,
        next_cursor: 3,
        previous_cursor: 1,
        has_more: false
      }
    );
    renderComponent();

    await waitFor(() => {
      expect(screen.queryAllByText('Product updates')).toHaveLength(2);
    });

    const checkbox = screen.queryAllByText('Product updates')[0];
    await fireEvent.click(checkbox);
    initGetSubscriptionsMock(200,
      { 
        limit: 10,
        pagination_direction: 'forward',
        category_guids: ['123-456-789']
      },
      {
        subscriptions: [mockSubscriptions[0]],
        next_cursor: 0,
        previous_cursor: 0,
        has_more: false
      }
    );
    await fireEvent.click(screen.getByText('Filter subscriptions'));
    await waitFor(() => {
      expect(screen.getByText('john@example.com')).toBeInTheDocument();
      expect(screen.queryAllByText('Product updates')).toHaveLength(2);
      expect(screen.queryByText('jane@example.com')).not.toBeInTheDocument();
    });
  });

  it('should filter subscriptions when multiple categories are selected', async () => {
    initGetCategoriesMock(200, mockCategories);
    initGetSubscriptionsMock(200, 
      { limit: 10, pagination_direction: 'forward' },
      {
        subscriptions: mockSubscriptions,
        next_cursor: 3,
        previous_cursor: 1,
        has_more: false
      }
    );
    renderComponent();

    await waitFor(() => {
      expect(screen.queryAllByText('Product updates')).toHaveLength(2);
      expect(screen.queryAllByText('Articles and market insights')).toHaveLength(2);
    });

    const productUpdatesCheckbox = screen.queryAllByText('Product updates')[0];
    const articlesCheckbox = screen.queryAllByText('Articles and market insights')[0];
    await fireEvent.click(productUpdatesCheckbox);
    await fireEvent.click(articlesCheckbox);

    initGetSubscriptionsMock(200,
      { 
        limit: 10,
        pagination_direction: 'forward',
        category_guids: ['123-456-789', '234-567-890']
      },
      {
        subscriptions: mockSubscriptions,
        next_cursor: 0,
        previous_cursor: 0,
        has_more: false
      }
    );
    await fireEvent.click(screen.getByText('Filter subscriptions'));
    await waitFor(() => {
      expect(screen.getByText('john@example.com')).toBeInTheDocument();
      expect(screen.getByText('jane@example.com')).toBeInTheDocument();
      expect(screen.queryAllByText('Product updates')).toHaveLength(2);
      expect(screen.queryAllByText('Articles and market insights')).toHaveLength(2);
    });
  });

  it('should enable users to be able to paginate forward and backward', async () => {
    initGetCategoriesMock(200, mockCategories);
    initGetSubscriptionsMock(200, 
      { limit: 10, pagination_direction: 'forward' },
      {
        subscriptions: page1Data,
        next_cursor: 3,
        previous_cursor: 1,
        has_more: true
      }
    );
    renderComponent();

    await waitFor(() => {
      expect(screen.getByText('alice@example.com')).toBeInTheDocument();
      expect(screen.getByText('bob@example.com')).toBeInTheDocument();
      expect(screen.getByText('charlie@example.com')).toBeInTheDocument();
      expect(screen.getByText('Next')).toBeInTheDocument();
      expect(screen.queryByText('Previous')).not.toBeInTheDocument();
    });

    initGetSubscriptionsMock(200,
      { 
        limit: 10,
        pagination_direction: 'forward',
        pagination_id: 3
      },
      {
        subscriptions: page2Data,
        next_cursor: 6,
        previous_cursor: 4,
        has_more: true
      }
    );

    // Paginate Forward
    await fireEvent.click(screen.getByText('Next'));
    await waitFor(() => {
      expect(screen.getByText('david@example.com')).toBeInTheDocument();
      expect(screen.getByText('eve@example.com')).toBeInTheDocument();
      expect(screen.getByText('frank@example.com')).toBeInTheDocument();
      expect(screen.queryByText('alice@example.com')).not.toBeInTheDocument();
      expect(screen.queryByText('bob@example.com')).not.toBeInTheDocument();
      expect(screen.queryByText('charlie@example.com')).not.toBeInTheDocument();
      expect(screen.getByText('Next')).toBeInTheDocument();
      expect(screen.getByText('Previous')).toBeInTheDocument();
    });

    initGetSubscriptionsMock(200,
      { 
        limit: 10,
        pagination_direction: 'forward',
        pagination_id: 6
      },
      {
        subscriptions: page3Data,
        next_cursor: 9,
        previous_cursor: 7,
        has_more: false
      }
    );

    await fireEvent.click(screen.getByText('Next'));
    await waitFor(() => {
      expect(screen.getByText('grace@example.com')).toBeInTheDocument();
      expect(screen.getByText('henry@example.com')).toBeInTheDocument();
      expect(screen.getByText('ivy@example.com')).toBeInTheDocument();
      expect(screen.queryByText('david@example.com')).not.toBeInTheDocument();
      expect(screen.queryByText('eve@example.com')).not.toBeInTheDocument();
      expect(screen.queryByText('frank@example.com')).not.toBeInTheDocument();
      expect(screen.queryByText('alice@example.com')).not.toBeInTheDocument();
      expect(screen.queryByText('bob@example.com')).not.toBeInTheDocument();
      expect(screen.queryByText('charlie@example.com')).not.toBeInTheDocument();
      expect(screen.queryByText('Next')).not.toBeInTheDocument();
      expect(screen.getByText('Previous')).toBeInTheDocument();
    });

    // Paginate Backward
    initGetSubscriptionsMock(200,
      { 
        limit: 10,
        pagination_direction: 'backward',
        pagination_id: 7
      },
      {
        subscriptions: page2Data,
        next_cursor: 6,
        previous_cursor: 4,
        has_more: true
      }
    );

    await fireEvent.click(screen.getByText('Previous'));
    await waitFor(() => {
      expect(screen.getByText('david@example.com')).toBeInTheDocument();
      expect(screen.getByText('eve@example.com')).toBeInTheDocument();
      expect(screen.getByText('frank@example.com')).toBeInTheDocument();
      expect(screen.queryByText('grace@example.com')).not.toBeInTheDocument();
      expect(screen.queryByText('henry@example.com')).not.toBeInTheDocument();
      expect(screen.queryByText('ivy@example.com')).not.toBeInTheDocument();
      expect(screen.queryByText('alice@example.com')).not.toBeInTheDocument();
      expect(screen.queryByText('bob@example.com')).not.toBeInTheDocument();
      expect(screen.queryByText('charlie@example.com')).not.toBeInTheDocument();
      expect(screen.getByText('Next')).toBeInTheDocument();
      expect(screen.getByText('Previous')).toBeInTheDocument();
    });

    initGetSubscriptionsMock(200,
      { 
        limit: 10,
        pagination_direction: 'backward',
        pagination_id: 4
      },
      {
        subscriptions: page1Data,
        next_cursor: 3,
        previous_cursor: 1,
        has_more: false
      }
    );

    await fireEvent.click(screen.getByText('Previous'));
    await waitFor(() => {
      expect(screen.getByText('alice@example.com')).toBeInTheDocument();
      expect(screen.getByText('bob@example.com')).toBeInTheDocument();
      expect(screen.getByText('charlie@example.com')).toBeInTheDocument();
      expect(screen.queryByText('david@example.com')).not.toBeInTheDocument();
      expect(screen.queryByText('eve@example.com')).not.toBeInTheDocument();
      expect(screen.queryByText('frank@example.com')).not.toBeInTheDocument();
      expect(screen.queryByText('grace@example.com')).not.toBeInTheDocument();
      expect(screen.queryByText('henry@example.com')).not.toBeInTheDocument();
      expect(screen.queryByText('ivy@example.com')).not.toBeInTheDocument();
      expect(screen.getByText('Next')).toBeInTheDocument();
      expect(screen.queryByText('Previous')).not.toBeInTheDocument();
    });
  });
});
