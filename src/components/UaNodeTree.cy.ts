import UaNodeTree from './UaNodeTree.vue'
import { uaApplication } from '../stores/UaState'
import * as OPCUA from 'opcua-client'

import { createPinia } from 'pinia'
import { UserTokenType } from 'opcua-client'

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
      EndpointUrl: 'opc.tcp://localhost:4841',
      TransportProfileUri: OPCUA.TransportProfile.TcpBinary,
      SecurityPolicyUri: OPCUA.SecurePolicyUri.None,
      SecurityMode: OPCUA.MessageSecurityMode.None,
      ServerCertificate: null,
      Token: {
        TokenPolicy: {
          PolicyId: 'anonymous',
          TokenType: UserTokenType.Anonymous,
          IssuedTokenType: undefined,
          IssuerEndpointUrl: undefined,
          SecurityPolicyUri: undefined
        },
        Identity: undefined,
        Secret: undefined
      }
    })

    cy.get("[ua-nodeid='i=84']").should('exist')
    cy.get("[ua-nodeid='i=84'] .node-row").should('exist')
    cy.get("[ua-nodeid='i=84'] .node-row .node-plus").should('exist')
    cy.get("[ua-nodeid='i=84'] .node-row .node-name").should('have.text', 'RootFolder')
    cy.get("[ua-nodeid='i=84'] .node-children").should('not.exist')
  })

  it('Browse RootFolder', () => {
    uaApplication(pinia).connect({
      EndpointUrl: 'opc.tcp://localhost:4841',
      TransportProfileUri: OPCUA.TransportProfile.TcpBinary,
      SecurityPolicyUri: OPCUA.SecurePolicyUri.None,
      SecurityMode: OPCUA.MessageSecurityMode.None,
      ServerCertificate: null,
      Token: {
        TokenPolicy: {
          PolicyId: 'anonymous',
          TokenType: UserTokenType.Anonymous,
          IssuedTokenType: undefined,
          IssuerEndpointUrl: undefined,
          SecurityPolicyUri: undefined
        },
        Identity: undefined,
        Secret: undefined
      }
    })

    cy.get("[ua-nodeid='i=84'] .node-plus").click()
    cy.get("[ua-nodeid='i=84'] .node-children").should('exist')
    cy.get("[ua-nodeid='i=84'] .node-children >").should('have.length', 3)
  })
})
