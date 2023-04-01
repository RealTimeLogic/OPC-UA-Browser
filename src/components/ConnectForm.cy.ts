import ConnectForm from './ConnectForm.vue'

describe('<ConnectForm />', () => {
  it('renders', () => {
    // see: https://on.cypress.io/mounting-vue
    cy.mount(ConnectForm)
  })
})