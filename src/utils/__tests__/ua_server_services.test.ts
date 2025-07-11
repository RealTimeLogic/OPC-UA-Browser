import { describe, it, expect, beforeEach, afterEach } from 'vitest'

import * as OPCUA from 'opcua-client'
import { RtlProxyClient } from '../ua_client_proxy'

const WebSockURL = 'ws://localhost:9357/opcua_client.lsp'
const EndpointURL = 'opc.tcp://vm-ubuntu:4841'

describe('Services', async () => {
  let server: RtlProxyClient

  beforeEach(async () => {
    server = new RtlProxyClient(WebSockURL)
    await server.connect()
    await server.hello(EndpointURL)
    await server.openSecureChannel(
      3600000,
      OPCUA.SecurePolicyUri.None,
      OPCUA.MessageSecurityMode.None
    )
    const session = await server.createSession('test_js_session', 3600000)
    let basic128Rsa15Edpoint: OPCUA.EndpointDescription | undefined
    for (const endpoint of session.ServerEndpoints) {
      if (endpoint.SecurityPolicyUri !== OPCUA.SecurePolicyUri.None) {
        basic128Rsa15Edpoint = endpoint
        break
      }
    }

    if (!basic128Rsa15Edpoint) {
      throw new Error('No basic128Rsa15Edpoint found')
    }

    let anonymousPolicy: OPCUA.UserTokenPolicy | undefined
    for (const tokenPolicy of basic128Rsa15Edpoint.UserIdentityTokens) {
      if (tokenPolicy.TokenType == OPCUA.UserTokenType.Anonymous) {
        anonymousPolicy = tokenPolicy
      }
    }

    if (!anonymousPolicy) {
      throw new Error('No anonymous policy found')
    }

    const activateResult = await server.activateSession(anonymousPolicy)
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
