import AuthForm from './AuthForm.vue'

describe('<AuthForm/>', () => {
  it('should mount', () => {
    // cy.debugger

    cy.mount(AuthForm)
    cy.get('input.endpoint-url').should('have.value', 'opc.tcp://localhost:4841')
    cy.get('input.fill-endpoints-button').should('exist')
    cy.get('input[type=button]').should('be.disabled')
  })

  it('Fill secure polices', () => {
    cy.mount(AuthForm)
    cy.get('input.fill-endpoints-button').click()

    cy.get('input.endpoint-url').should('have.value', 'opc.tcp://localhost:4841')
    cy.get('input[name="endpoint"]').should('exist')
    cy.get('input[name="endpoint"]').should('have.length', 3)
    cy.get('input[type=button]').should('be.disabled')
  })

  it('Fill secure polices', () => {
    cy.mount(AuthForm)
    cy.get('input.endpoint-url').should('have.value', 'opc.tcp://localhost:4841')
    cy.get('input.fill-endpoints-button').click()
    cy.get('input[name="endpoint"').should('have.length', 3)

    cy.get('input[name="endpoint"]:first').check()

    cy.get('input[name="userToken"').should('have.length.gt', 0)
    cy.get('input[name="userToken"]:first').check()

    cy.get('input[type=button]').should('be.enabled')
  })

  it('Sends event on selected endpoint', () => {
    cy.mount(AuthForm)
    cy.document().then((doc) => {
      doc.addEventListener("endpoint", cy.stub().as('endpoint'))
    })

    cy.mount(AuthForm)
    cy.get('input.endpoint-url').should('have.value', 'opc.tcp://localhost:4841')
    cy.get('input.fill-endpoints-button').click()
    cy.get('input[name="endpoint"]:first').check()
    cy.get('input[name="userToken"]:first').check()
    cy.get('input.connect-button').click()

    cy.get("@endpoint").should("have.been.calledOnce")
  })
})
