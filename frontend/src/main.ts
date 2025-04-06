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
      path: '/',
      name: 'subscription',
      component: () => import('./views/subscription/components/Subscription.vue')
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
