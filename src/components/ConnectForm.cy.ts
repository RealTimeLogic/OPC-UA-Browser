import ConnectForm from './ConnectForm.vue'

describe('ConnectForm', () => {
  it('should mount', () => {
    cy.mount(ConnectForm)

    cy.get('input').should('contain.text', '')
  })
})
