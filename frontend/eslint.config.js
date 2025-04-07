import { defineConfig } from "eslint/config";
import globals from "globals";
import js from "@eslint/js";
import tseslint from "typescript-eslint";
import pluginVue from "eslint-plugin-vue";

export default defineConfig([
  // Base files (applies to everything)
  { files: ["**/*.{js,mjs,cjs,ts,vue}"] },

  // Browser globals for regular files
  {
    files: ["**/*.{js,mjs,cjs,ts,vue}"],
    languageOptions: {
      globals: globals.browser,
    },
  },

  // Node globals for config files like babel.config.cjs
  {
    files: ["**/*.cjs"],
    languageOptions: {
      globals: globals.node,
    },
  },

  // JS rules with semicolon enforcement
  {
    files: ["**/*.{js,mjs,cjs,ts,vue}"],
    plugins: { js },
    extends: ["js/recommended"],
    rules: {
      semi: ["error", "always"], // 👈 Enforce semicolon usage
    },
  },

  // TypeScript rules
  tseslint.configs.recommended,

  // Vue rules
  pluginVue.configs["flat/essential"],

  // Vue with TS parser
  {
    files: ["**/*.vue"],
    languageOptions: {
      parserOptions: {
        parser: tseslint.parser,
      },
    },
  },
]);
