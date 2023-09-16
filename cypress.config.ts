import { defineConfig } from 'cypress';

export default defineConfig({
  e2e: {
    setupNodeEvents () {
      // implement node event listeners here
    },
    env: {
      baseUrl: 'http://localhost:5173/'
    }
  }
});
