import { createI18n } from 'vue-i18n'
import en from './en.json'

export default createI18n({
  legacy: false, // Set to false to use Composition API
  locale: 'en',
  messages: {
    en
  }
})
