import { createApp } from 'vue'
import { createRouter, createWebHistory } from 'vue-router'
import i18n from './i18n'

// Styles
import './style.css'

// Components
import App from './App.vue'

// Router
const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/subscription',
      name: 'subscription',
      component: () => import('./pages/subscription/components/Subscription.vue')
    },
    {
      path: '/subscription/list',
      name: 'subscription-list',
      component: () => import('./pages/subscription/components/SubscriptionList.vue')
    }
  ]
})

// Create app
const app = createApp(App)

// Use plugins
app.use(router)
app.use(i18n)

// Mount app
app.mount('#app')
