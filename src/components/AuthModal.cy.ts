import AuthModal from './AuthModal.vue'
import "bootstrap/dist/js/bootstrap.min"

describe('<AuthForm/>', () => {
  beforeEach(() => {
    cy.mount(AuthModal) 
    cy.window().then((win) => {
      const elem = win.document.getElementById('auth-dialog')
      elem.style.display = "block"
    })
  })

  it('should mount', () => {
    cy.get('input.endpoint-url').should('have.value', 'opc.tcp://localhost:4841')
    cy.get('button.fill-endpoints-button').should('exist')
    cy.get('button.login-button').should('be.disabled')
  })

  it('Fill secure polices', () => {
    cy.get('button.fill-endpoints-button').click()
    cy.get('input.endpoint-url').should('have.value', 'opc.tcp://localhost:4841')

    cy.get('.endpoint-params').should('exist')
    cy.get('.endpoint-params').should('have.length', 3)

    cy.get('button.login-button').should('be.disabled')
  })

  it('Selecting token enables login button', () => {
    cy.get('button.fill-endpoints-button').click()
    cy.get('input.endpoint-url').should('have.value', 'opc.tcp://localhost:4841')

    cy.get('.endpoint-params').should('exist')
    cy.get('.endpoint-params').should('have.length', 3)
    cy.get('.endpoint-params:first').click()

    cy.get('input[type="radio"]:first').check()

    cy.get('button.login-button').should('be.enabled')
  })

  it('Sends event on login click', () => {
    cy.document().then((doc) => {
      doc.addEventListener("endpoint", cy.stub().as('endpoint'))
    })

    cy.get('button.fill-endpoints-button').click()
    cy.get('.endpoint-params:first').click()
    cy.get('input[type="radio"]:first').check()
    cy.get('button.login-button').click()

    cy.get("@endpoint").should("have.been.calledOnce")
  })
})
