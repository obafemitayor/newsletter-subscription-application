<template>
    <div class="container">
        <div class="form">
            <div class="form-group">
                <div class="form-element">
                    <input type="text" 
                        :aria-label="$t('subscription.inputs.firstName')"
                        v-model="subscription.firstName" 
                        :placeholder="$t('subscription.inputs.firstName')"
                        @blur="validateFormField('firstName', subscription.firstName)"
                        :class="{ 'first-name': true, 'error': errors.firstName }"
                    >
                    <span v-if="errors.firstName" class="error-message">{{ errors.firstName }}</span> 
                </div>
                <div class="form-element">
                    <input type="text"
                        :aria-label="$t('subscription.inputs.lastName')"
                        v-model="subscription.lastName" 
                        :placeholder="$t('subscription.inputs.lastName')"
                        @blur="validateFormField('lastName', subscription.lastName)"
                        :class="{ 'last-name': true, 'error': errors.lastName }"
                    >
                    <span v-if="errors.lastName" class="error-message">{{ errors.lastName }}</span>
                </div>
            </div>

            <div class="form-group">
                <div class="form-element">
                    <input 
                        :aria-label="$t('subscription.inputs.workEmail')"
                        type="email" 
                        v-model="subscription.workEmail" 
                        :placeholder="$t('subscription.inputs.workEmail')"
                        @blur="validateFormField('workEmail', subscription.workEmail)"
                        :class="{ 'input': true, 'error': errors.workEmail }"
                    >
                    <span v-if="errors.workEmail" class="error-message">{{ errors.workEmail }}</span> 
                </div>
            </div>

            <div class="categories" :class="{ 'error': errors.categories }">
                <span class="categories-title">{{ $t('subscription.categories.title') }}</span>

                <template v-if="categories.length > 0">
                    <label 
                        v-for="category in categories" 
                        :key="category.guid" 
                        class="categories-checkbox"
                    >
                        <input 
                            :aria-label="$t('subscription.categories.checkbox', { category: category.name })"
                            type="checkbox" 
                            v-model="subscription.categoryGuids" 
                            :value="category.guid"
                        >
                        <span class="check-box-checkmark"></span>
                        <span class="categories-label">{{ category.name }}</span>
                    </label>
                </template>
                <span v-if="errors.categories" class="error-message">{{ errors.categories }}</span>
            </div>

            <div>
                <span class="privacy-text">
                    {{ $t('subscription.privacy.text') }} 
                    <a href="" class="privacy-link">{{ $t('subscription.privacy.link') }}</a>.
                </span>
            </div>

            <button 
                type="button" 
                @click="createSubscription" 
                class="submit-button"
            >
                {{ $t('subscription.submit') }}
            </button>
        </div>
    </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useI18n } from 'vue-i18n'
import type { Category, SubscriptionData, ValidationErrors } from '../types/types'
import { fetchCategories } from '../service/category'
import { createSubscriptionForCustomer } from '../service/subscription'
import { validateField } from '../helpers/validation'

const { t } = useI18n()

const categories = ref<Category[]>([])
const errors = ref<ValidationErrors>({
  firstName: '',
  lastName: '',
  workEmail: '',
  categories: ''
})

const subscription = ref<SubscriptionData>({
  firstName: '',
  lastName: '',
  workEmail: '',
  categoryGuids: []
})

const validateFormField = (field: keyof ValidationErrors, value: string | string[]) => {
  errors.value[field] = ''
  const validation = validateField(field, value, t)
  errors.value[field] = validation.errorMessage
  return validation.isValid
}

const createSubscription = async () => {
  const isFirstNameValid = validateFormField('firstName', subscription.value.firstName);
  const isLastNameValid = validateFormField('lastName', subscription.value.lastName);
  const isEmailValid = validateFormField('workEmail', subscription.value.workEmail);
  const isCategoriesValid = validateFormField('categories', subscription.value.categoryGuids);

  if (!isFirstNameValid || !isLastNameValid || !isEmailValid || !isCategoriesValid) {
    return;
  }

  try {
    await createSubscriptionForCustomer({
      first_name: subscription.value.firstName,
      last_name: subscription.value.lastName,
      work_email: subscription.value.workEmail,
      category_guids: subscription.value.categoryGuids
    })
    alert(t('alerts.subscription.success'))
    subscription.value = {
      firstName: '',
      lastName: '',
      workEmail: '',
      categoryGuids: []
    }
  } catch (error) {
    alert(t('alerts.subscription.error'))
  }
}

onMounted(async () => {
  try {
    categories.value = await fetchCategories()
  } catch (error) {
    alert(t('alerts.categories.error'))
  }
})
</script>

<style scoped>
.container {
    width: 500px;
    position: relative;
    border-radius: 10px;
    padding: 40px;
    margin-right: auto;
    background-color: #f1ecf6;
    font-family: Roboto, sans-serif;
}

.form {
    width: 500px;
    display: flex;
    flex-direction: column;
    gap: 20px;
    position: relative;
}

.form-group {
    width: 100%;
    display: flex;
    flex-direction: row;
}

.form-group .form-element{
    display: flex;
    flex-direction: column;
    align-items: stretch;
    flex: 1;
    gap: 5px;
}

.form-element input {
    height: 36px;
    padding: 10px;
    border: 0.3px solid rgba(0, 0, 0, 0.1);
    border-radius: 8px;
    font-size: 14px;
    outline: none;
    background: white;
}

.form-element input:focus{
    border: 1px solid #73467B;
}

input.first-name {
    border-top-right-radius: 0px;
    border-bottom-right-radius: 0px;
}

input.last-name {
    border-top-left-radius: 0px;
    border-bottom-left-radius: 0px;
}

.form-element input.error {
    border-color: #dc3545 !important;
    border-width: 1px;
}

.error-message {
    color: #dc3545;
    font-size: 0.75rem;
}

.input::placeholder {
    color: rgba(0, 0, 0, 0.6);
}

.categories {
    display: flex;
    flex-direction: column;
    gap: 10px;
}

.categories-title {
    font-family: Roboto, sans-serif;
    font-size: 14px;
    font-weight: 400;
    line-height: 20px;
    color: #74777E;
    align-self: flex-start;
}

.categories-checkbox {
    display: flex;
    align-items: center;
    margin-bottom: 0.75rem;
    cursor: pointer;
}

.categories-label {
    font-family: Roboto, sans-serif;
    font-size: 14px;
    font-weight: 400;
    line-height: 20px;
    color: #5B6278;
}

.categories-checkbox input[type="checkbox"] {
    position: absolute;
    opacity: 0;
    cursor: pointer;
}

.check-box-checkmark {
    height: 20px;
    width: 20px;
    background-color: white;
    border: 1px solid rgba(0, 0, 0, 0.2);
    border-radius: 6px;
    margin-right: 1rem;
    position: relative;
}

.categories-checkbox input:checked ~ .check-box-checkmark {
    background-color: #6750A4;
    border-color: #6750A4;
}

.categories-checkbox input:checked ~ .check-box-checkmark:after {
    content: "";
    position: absolute;
    left: 6px;
    top: 3px;
    width: 5px;
    height: 9px;
    border: solid white;
    border-width: 0 2px 2px 0;
    transform: rotate(45deg);
}

.privacy-text {
    font-weight: 400;
    font-size: 14px;
    line-height: 20px;
    color: rgba(0, 0, 0, 0.6);
    font-family: Roboto, sans-serif;
    text-align: left;
    display: block;
}

.privacy-link {
    font-family: Roboto, sans-serif;
    font-size: 14px;
    font-weight: 400;
    line-height: 20px;
    text-decoration: underline;
}

.submit-button {
    background-color: #73467B;
    color: #FFFFFF;
    border: none;
    border-radius: 8px;
    padding: 9px 21px;
    width: 114px;
    height: 42px;
    cursor: pointer;
    font-family: Roboto, sans-serif;
    font-size: 16px;
    font-weight: 500;
}

.submit-button:hover {
    opacity: 0.9;
}
</style>
