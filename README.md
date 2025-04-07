# 📬 Storyblok's Newsletter Subscription App
This is a web application that allows users to subscribe to newsletters that are focussed on different topics. The web app has two pages which are:
1. [Subscription Page](http://localhost:5173/subscription) which allows users to fill a subscription form with basic personal details and select newsletter categories
2. [Subscription List Page](http://localhost:5173/subscription/list) which allows users to view all submitted subscriptions and filter subscriptions by category.

[Here](https://www.loom.com/share/0b77263a3a7445ef8020b1fbda6f6209) is a short video that demonstrates what the application looks like
---
## 🗂️ Basic Repository Folder Structure

```bash
story-blok-newsletter-subscription-application/
├── api/
│   ├── app/
│   │   ├── controllers/
│   │   │   └── v1/
│   │   │       ├── categories_controller.rb
│   │   │       └── subscriptions_controller.rb
│   │   ├── models/
│   │   │   ├── category.rb
│   │   │   ├── customer.rb
│   │   │   ├── subscription.rb
│   │   ├── services/
│   │   │   ├── category_service.rb
│   │   │   └── subscription_service.rb
│   ├── spec/
│   │   ├── controllers/
│   │   ├── models/
│   │   ├── services/
│   │   └── factories/
│   ├── Dockerfile
│   ├── docker-compose.yml
│
├── frontend/
│   ├── src/
│   │   ├── main.ts
│   │   ├── pages/
│   │   │   └── subscription/
│   │   │       ├── components/
│   │   │       │   ├── SubscriptionForm.vue
│   │   │       │   └── SubscriptionList.vue
│   │   │       ├── service/
│   │   │       │   ├── category.ts
│   │   │       │   └── subscription.ts
│   │   │       ├── helpers/
│   │   │       │   ├── constants.ts
│   │   │       │   └── validation.ts
│   │   │       └── types/
│   └── __tests__/
│       ├── SubscriptionForm.test.ts
│       ├── SubscriptionList.test.ts
│       └── utils/
│           ├── categories-mock-data.ts
│           ├── subscription-list-mock-data.ts
│           └── utils.ts
│
└── README.md
```

---

## 🚀 Getting Started

### Prerequisites
- `Docker`: You must have either [docker desktop](https://www.docker.com/products/docker-desktop) or [orb stack](https://orbstack.dev/) (recommended) installed. Note that orb stack only works on mac and linux.
- `Node`: with version greater than or equal to `20.10.0`

### ⚙️ Setup
- Navigate to the root directory of the api folder.
- Run `docker compose build --no-cache` to build the containers.
- Run `docker compose run --rm api bundle install` to install the gem packages.
- Run `docker compose run --rm api rails db:migrate` to migrate the database.
- Run `docker compose up api -d` to start the containers.
- Launch http://localhost:3000 on your browser to confirm that the API server is running.
- Navigate to the root directory of the frontend folder.
- Run `npm install` to install dependencies.
- Run `npm run dev` to start the development server.
- Launch http://localhost:5173/subscription on your browser to confirm that the frontend server is running.
- The create subscription page url is http://localhost:5173/subscription, while the subscription list page url is http://localhost:5173/subscription/list
---

## 🧪 Running Tests

### Backend Tests
- Navigate to the root directory of the api folder.
- Run `docker compose up test` to run the tests.

### Frontend Tests
- Navigate to the root directory of the frontend folder.
- Run `npm run test` to run the tests.
---

## 🔧 Things to Improve
Here is a list of things that I would like to improve but couldn't due to time constraints:
- Add end to end tests with `Cypress`
- Add caching for the categories to prevent frequent database queries as that dataset would not change often
- Use a proper localization tool that can automatically manage translations
- Add visual feedback for loading and success/failure states
- Improve the UI rendering for the categories a customer has subscribed to on the subscription list page
- Use toasts or a proper notification library instead of using `alert()`
- Add a proper UI for visual feedback when there was an error fetching categories on the subscription and subscription list pages
- Add a not found page for visual feedback when a route that does not exist is accessed
---
