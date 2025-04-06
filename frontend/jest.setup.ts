import '@testing-library/jest-dom'
import { config } from '@vue/test-utils'

Object.defineProperty(global, 'matchMedia', {
  writable: true,
  value: jest.fn().mockImplementation(query => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: jest.fn(),
    removeListener: jest.fn(),
    addEventListener: jest.fn(),
    removeEventListener: jest.fn(),
    dispatchEvent: jest.fn(),
  })),
})

config.global.mocks = {
  $t: (msg: string) => msg
}

global.alert = jest.fn()
