import UaNodeTree from './UaNodeTree.vue'
import { uaApplication } from '../stores/UaState'
import { OPCUA } from '../utils/ua_server'
                                     
import { createPinia } from "pinia"

const pinia = createPinia()

describe('<AuthForm/>', () => {
  beforeEach(() => {

    cy.mount(UaNodeTree, {
      global: {
        plugins: [pinia]
      }
    }) 
  })

  it('should mount empty', () => {
    cy.get("[ua-nodeid='i=84']").should('not.exist')
  })

  it('Root node appear connect', () => {
    uaApplication(pinia).connect({
      endpointUrl: "opc.tcp://localhost:4841",
      securityPolicyUri: OPCUA.SecurePolicyUri.None,
      token: {
        policyId: "anonymous"
      }
    })

    cy.get("[ua-nodeid='i=84']").should('exist')
    cy.get("[ua-nodeid='i=84'] .node-row").should('exist')
    cy.get("[ua-nodeid='i=84'] .node-row .node-plus").should('exist')
    cy.get("[ua-nodeid='i=84'] .node-row .node-name").should('have.text', "RootFolder")
    cy.get("[ua-nodeid='i=84'] .node-children").should('not.exist')
  })

  it('Browse RootFolder', () => {
    uaApplication(pinia).connect({
      endpointUrl: "opc.tcp://localhost:4841",
      securityPolicyUri: OPCUA.SecurePolicyUri.None,
      token: {
        policyId: "anonymous"
      }
    })

    cy.get("[ua-nodeid='i=84'] .node-plus").click()
    cy.get("[ua-nodeid='i=84'] .node-children").should('exist')
    cy.get("[ua-nodeid='i=84'] .node-children >").should('have.length', 3)
  })
})
