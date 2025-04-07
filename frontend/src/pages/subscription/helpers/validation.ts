import type { Validation } from '../types/types';

type LocaliseFunction = (key: string, params?: Record<string, string>) => string;

const validateRequiredField = (field: string, value: string, localise: LocaliseFunction) => {
    if(!value.trim()) {
        return {
            isValid: false,
            errorMessage: localise('validation.required', { field: field })
        };
    }

    return {
        isValid: true,
        errorMessage: ''
    };
};

const validateCategories = (categoryGuids: string[], localise: LocaliseFunction): Validation =>  {
    if(categoryGuids.length === 0) {
        return {
            isValid: false,
            errorMessage: localise('validation.categories.required')
        };
    }

    return {
        isValid: true,
        errorMessage: ''
    };
};

const validateEmail = (email: string, localise: LocaliseFunction): Validation => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if(!emailRegex.test(email)) {
        return {
            isValid: false,
            errorMessage: localise('validation.email.invalid')
        };
    }

    return {
        isValid: true,
        errorMessage: ''
    };
};

export const validateField = (field: string, value: string | string[], localise: LocaliseFunction): Validation => {
    if(field === 'firstName' || field === 'lastName') {
        return validateRequiredField(field, value as string, localise);
    }

    if(field === 'workEmail') {
        return validateEmail(value as string, localise);
    }

    if(field === 'categories') {
        return validateCategories(value as string[], localise);
    }

    return {
        isValid: true,
        errorMessage: ''
    };
};