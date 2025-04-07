import { createI18n } from 'vue-i18n';

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
        categories: {
          error: 'Failed to fetch categories, please try again'
        },
        subscriptionList: {
          error: 'Failed to fetch subscriptions'
        },
        subscription: {
          success: 'Subscription created successfully',
          error: 'Failed to create subscription, please try again'
        }
      },
      subscriptionList: {
        title: "Subscriptions",
        filter: {
          button: "Filter subscriptions",
          checkbox: "Filter subscriptions by {category}"
        },
        table: {
          email: "Work Email",
          firstName: "First Name",
          lastName: "Last Name",
          category: "Category",
          noData: "No subscriptions found"
        },
        pagination: {
          loadPrevious: "Previous",
          loadNext: "Next"
        }
      }
    }
  }
});

export default i18n;