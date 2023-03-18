import ConnectForm from './ConnectForm.vue'

describe('<ConnectForm/>', () => {
  it('should mount', () => {
    cy.mount(ConnectForm)

    cy.get('input.endpoint-url').should('have.value', 'opc.tcp://localhost:4841')
    cy.get('input.fill-endpoints-button').should('exist')
    cy.get('select#securityMode').should('be.disabled')
    cy.get('input[type=button]').should('be.disabled')
  })

  it('Fill secure polices', () => {
    cy.mount(ConnectForm)
    cy.get('input.fill-endpoints-button').click()

    cy.get('input.endpoint-url').should('have.value', 'opc.tcp://localhost:4841')
    cy.get('select#securityMode').should('be.enabled')
    cy.get('select#securityMode').should('have.value', 0)
    cy.get('select#securityMode > *').should('have.length', 3)
    
    cy.get('input[type=button]').should('be.enabled')
  })

  it('Sends event on selected endpoint', () => {
    cy.mount(ConnectForm)
    cy.document().then((doc) => {
      doc.addEventListener("endpoint", cy.stub().as('endpoint'))
    })

    cy.get('input.fill-endpoints-button').click()

    cy.get('input.connect-button').click()

    cy.get("@endpoint").should("have.been.calledOnce")
  })
})
