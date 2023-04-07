import { defineConfig } from "cypress";

export default defineConfig({
  e2e: {
    supportFile: false,
    specPattern: "tests_e2e/**/*.cy.ts",
    baseUrl: "http://localhost",
  },

  component: {
    specPattern: "src/**/*.cy.ts",
    devServer: {
      framework: "vue",
      bundler: "vite",
    },
  },
});
