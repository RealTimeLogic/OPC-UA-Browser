import { describe, it, expect, beforeEach, afterEach } from 'vitest'

import * as OPCUA from 'opcua-client'
import { RtlProxyClient } from '../ua_server'

const WebSockURL = 'ws://localhost/opcua_client.lsp'
const EndpointURL = 'opc.tcp://localhost:4841'

describe('Services', async () => {
  let server: OPCUA.UAServer

  beforeEach(async () => {
    server = new RtlProxyClient(WebSockURL)
    await server.hello(EndpointURL)
    await server.openSecureChannel(
      3600000,
      OPCUA.SecurePolicyUri.None,
      OPCUA.MessageSecurityMode.None
    )
    const session: any = await server.createSession('test_js_session', 3600000)
    let basic128Rsa15Edpoint: any
    for (const endpoint of session.serverEndpoints) {
      if (endpoint.securityPolicyUri == OPCUA.SecurePolicyUri.Basic128Rsa15) {
        basic128Rsa15Edpoint = endpoint
        break
      }
    }

    let anonymousPolicyId: string = ''
    for (const tokenPolicy of basic128Rsa15Edpoint.userIdentityTokens) {
      if (tokenPolicy.tokenType == OPCUA.UserTokenType.Anonymous) {
        anonymousPolicyId = tokenPolicy.policyId
      }
    }

    expect(anonymousPolicyId).not.toEqual('')
    const activateResult = await server.activateSession(anonymousPolicyId)
    expect(activateResult).to.toBeDefined()
  })

  afterEach(async () => {
    await server.closeSession()
    await server.closeSecureChannel()
  })

  it('Browse', async () => {
    const browseResult = await server.browse('i=84')
    expect(browseResult).not.to.toEqual(false)
  })
})
