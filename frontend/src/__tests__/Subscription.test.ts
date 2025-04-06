import { render, screen, waitFor, fireEvent } from '@testing-library/vue'
import { createI18n } from 'vue-i18n'
import Subscription from '../views/subscription/components/Subscription.vue'
import axios from 'axios'
import type { Category, SubscriptionPayload } from '../views/subscription/types/types'

const realAxiosGet = axios.get
jest.mock('axios')
const mockedAxios = axios as jest.Mocked<typeof axios>;
const alertMock = jest.spyOn(window, 'alert').mockImplementation();
const BASE_URL = 'http://localhost:3000/v1'

const initGetCategoriesMock = (status: number, categories: Category[] | null, error: Error | null = null) => {
  mockedAxios.get.mockImplementationOnce((url: string, config) => {
    if (url === `${BASE_URL}/categories`) {
      return status === 200 ? Promise.resolve({ data: { categories } }) : Promise.reject(error);
    }
    return realAxiosGet(url, config)
  })
}

const initCreateSubscriptionMock = (status: number, payload: SubscriptionPayload, error: Error | null = null) => {
  mockedAxios.post.mockImplementationOnce((url: string, data: unknown, config) => {
    if (url === `${BASE_URL}/subscriptions` && JSON.stringify(data) === JSON.stringify(payload)) {
      return status === 200 ? Promise.resolve({ data: null }) : Promise.reject(error);
    }
    return realAxiosGet(url, config)
  })
}

const i18n = createI18n({
  legacy: false,
  locale: 'en',
  messages: {
    en: {
      subscription: {
        inputs: {
          firstName: 'First name',
          lastName: 'Last name',
          workEmail: 'Work Email'
        },
        categories: {
          title: 'Newsletter Categories',
          checkbox: 'Subscribe to {category}'
        },
        privacy: {
          text: 'By subscribing you agree to our',
          link: 'Privacy Policy'
        },
        submit: 'Subscribe'
      },
      validation: {
        required: '{field} is required',
        email: {
          invalid: 'Please enter a valid email address'
        },
        categories: {
          required: 'Please select at least one category'
        }
      },
      alerts: {
        subscription: {
          success: 'Subscription created successfully',
          error: 'Failed to create subscription, please try again'
        },
        categories: {
          error: 'Failed to fetch categories, please try again'
        }
      }
    }
  }
})

const renderComponent = () => {
  return render(Subscription, {
    global: {
      plugins: [i18n]
    }
  })
}

const mockCategories = [
  { guid: '123-456-789', name: 'Product updates' },
  { guid: '234-567-890', name: 'Market insights' }
]

describe('Subscription Page', () => {
  beforeEach(() => {
    mockedAxios.get.mockReset();
    mockedAxios.post.mockReset();
    alertMock.mockRestore();
  })

  afterAll(() => {
    mockedAxios.get.mockReset();
    mockedAxios.post.mockReset();
    alertMock.mockRestore();
  })

  it('should render correctly and display the form when the category list was fetched successfully', async () => {
    initGetCategoriesMock(200,mockCategories);
    renderComponent();
    expect(screen.getByPlaceholderText('First name')).toBeInTheDocument();
    expect(screen.getByPlaceholderText('Last name')).toBeInTheDocument();
    expect(screen.getByPlaceholderText('Work Email')).toBeInTheDocument();
    await waitFor(() => {
      expect(screen.getByText('Newsletter Categories')).toBeInTheDocument();
      expect(screen.getByText('Product updates')).toBeInTheDocument();
      expect(alertMock).not.toHaveBeenCalled();
    })
  })

  it('should display an error alert when the category list was not fetched successfully', async () => {
    initGetCategoriesMock(500, null, new Error('Failed to fetch categories'));
    renderComponent();
    expect(screen.getByPlaceholderText('First name')).toBeInTheDocument();
    expect(screen.getByPlaceholderText('Last name')).toBeInTheDocument();
    expect(screen.getByPlaceholderText('Work Email')).toBeInTheDocument();
    await waitFor(() => {
      expect(alertMock).toHaveBeenCalledWith('Failed to fetch categories, please try again');
    })
  })

  it('should display validation error when first name or last name is empty', async () => {
    initGetCategoriesMock(200, mockCategories);
    renderComponent()

    await waitFor(() => {
      expect(screen.getByText('Newsletter Categories')).toBeInTheDocument();
      expect(screen.getByText('Product updates')).toBeInTheDocument();
    })
    await fireEvent.update(screen.getByPlaceholderText('First name'), '')
    await fireEvent.blur(screen.getByPlaceholderText('First name'))
    await fireEvent.update(screen.getByPlaceholderText('Last name'), '')
    await fireEvent.blur(screen.getByPlaceholderText('Last name'))

    await waitFor(() => {
      expect(screen.getByText('firstName is required')).toBeInTheDocument()
      expect(screen.getByText('lastName is required')).toBeInTheDocument()
    })
  })

  it('should display validation error when email is invalid', async () => {
    initGetCategoriesMock(200, mockCategories);
    renderComponent()

    await waitFor(() => {
      expect(screen.getByText('Newsletter Categories')).toBeInTheDocument();
      expect(screen.getByText('Product updates')).toBeInTheDocument();
    })

    await fireEvent.update(screen.getByPlaceholderText('First name'), 'John')
    await fireEvent.update(screen.getByPlaceholderText('Last name'), 'Doe')
    await fireEvent.update(screen.getByPlaceholderText('Work Email'), 'invalid-email')
    await fireEvent.blur(screen.getByPlaceholderText('Work Email'))

    await waitFor(() => {
      expect(screen.queryByText('firstName is required')).not.toBeInTheDocument()
      expect(screen.queryByText('lastName is required')).not.toBeInTheDocument()
      expect(screen.getByText('Please enter a valid email address')).toBeInTheDocument()
    })
  })

  it('should display validation error when at least one category is not selected', async () => {
    initGetCategoriesMock(200, mockCategories);
    renderComponent()

    await waitFor(() => {
      expect(screen.getByText('Newsletter Categories')).toBeInTheDocument();
      expect(screen.getByText('Product updates')).toBeInTheDocument();
    })

    await fireEvent.update(screen.getByPlaceholderText('First name'), 'John')
    await fireEvent.update(screen.getByPlaceholderText('Last name'), 'Doe')
    await fireEvent.update(screen.getByPlaceholderText('Work Email'), 'johndoe@example.com')
    const submitButton = screen.getByText('Subscribe')
    await fireEvent.click(submitButton)

    await waitFor(() => {
      expect(screen.queryByText('firstName is required')).not.toBeInTheDocument()
      expect(screen.queryByText('lastName is required')).not.toBeInTheDocument()
      expect(screen.queryByText('Please enter a valid email address')).not.toBeInTheDocument()
      expect(screen.getByText('Please select at least one category')).toBeInTheDocument()
    })
  })

  it('should display success alert when the subscription creation for the customer was successful', async () => {
    initGetCategoriesMock(200, mockCategories);
    initCreateSubscriptionMock(200, {
      first_name: 'John',
      last_name: 'Doe',
      work_email: 'john@example.com',
      category_guids: ['123-456-789']
    });
    renderComponent()

    await waitFor(() => {
      expect(screen.getByText('Newsletter Categories')).toBeInTheDocument();
      expect(screen.getByText('Product updates')).toBeInTheDocument();
    })

    await fireEvent.update(screen.getByPlaceholderText('First name'), 'John')
    await fireEvent.update(screen.getByPlaceholderText('Last name'), 'Doe')
    await fireEvent.update(screen.getByPlaceholderText('Work Email'), 'john@example.com')
    const checkbox = screen.getByLabelText('Product updates')
    await fireEvent.click(checkbox)
    await fireEvent.click(screen.getByText('Subscribe'))

    await waitFor(() => {
      expect(alertMock).toHaveBeenCalledWith('Subscription created successfully')
    })
  })

  it('should display error alert when the subscription creation for the customer failed', async () => {
    initGetCategoriesMock(200, mockCategories);
    initCreateSubscriptionMock(500, {
      first_name: 'John',
      last_name: 'Doe',
      work_email: 'john@example.com',
      category_guids: ['123-456-789']
    }, new Error('Failed to create subscription'));
    renderComponent()

    await waitFor(() => {
      expect(screen.getByText('Newsletter Categories')).toBeInTheDocument();
      expect(screen.getByText('Product updates')).toBeInTheDocument();
    })

    await fireEvent.update(screen.getByPlaceholderText('First name'), 'John')
    await fireEvent.update(screen.getByPlaceholderText('Last name'), 'Doe')
    await fireEvent.update(screen.getByPlaceholderText('Work Email'), 'john@example.com')
    const checkbox = screen.getByLabelText('Product updates')
    await fireEvent.click(checkbox)
    await fireEvent.click(screen.getByText('Subscribe'))

    await waitFor(() => {
      expect(alertMock).not.toHaveBeenCalledWith('Subscription created successfully')
      expect(alertMock).toHaveBeenCalledWith('Failed to create subscription, please try again')
    })
  })
})
