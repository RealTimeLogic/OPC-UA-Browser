import { describe, it, expect, beforeEach, afterEach } from 'vitest'

import * as OPCUA from 'opcua-client'
import { RtlProxyClient as UAServer } from '../ua_server'


const WebSockURL = 'ws://localhost:9357/opcua_client.lsp'
const EndpointURL = 'opc.tcp://vm-ubuntu:4841/opcua/'

describe('Websocket connecting', async () => {
  it('Connects to websocket', async () => {
    const server = new UAServer(WebSockURL)
    await server.connect()
    const connectResult = await server.hello(EndpointURL)
    expect(connectResult).to.equal(undefined)

    const disconnectResult = await server.disconnect()
    expect(disconnectResult).to.equal(server)
  })

  it('second connect not possible', async () => {
    const server = new UAServer(WebSockURL)
    const connectResult = await server.connect()
    expect(connectResult).to.equal(server)

    await expect(server.connect()).rejects.toThrowError(new Error('already connected'))

    const disconnectResult = await server.disconnect()
    expect(disconnectResult).to.equal(server)
  })

  it('second disconnect not possible', async () => {
    const server = new UAServer(WebSockURL)
    await server.connect()
    await server.disconnect()
    await expect(server.disconnect()).rejects.toThrowError(
      new Error('already disconnected')
    )
  })

  it('Disconnect callback called', async () => {
    let error = undefined
    const onDisconnect = (e: Error) => {
      error = e
    }

    const server = new UAServer(WebSockURL, onDisconnect)

    const connectResult = await server.connect()
    expect(connectResult).to.equal(server)

    server.disconnect()

    expect(error).not.toEqual(null)
  })
})

describe('Connect to OPCUA endpoint', async () => {
  let server: UAServer

  beforeEach(async () => {
    server = new UAServer(WebSockURL)
    await server.connect()
  })

  afterEach(async () => {
    await server.disconnect()
  })

  it('Connect/disconnect OPCUA server', async () => {
    const opening = await server.hello(EndpointURL)
    expect(opening).not.to.toBeDefined()
  })

  it('Fails to connect to unavailable server', async () => {
    // Add a number to port
    expect(server.hello(EndpointURL + '2')).rejects.toThrowError()
  })
})

describe('OpenSecureChannel SecurePolicy None', async () => {

  it('OpenSecure channel without connect', async () => {
    const server = new UAServer(WebSockURL)
    await server.connect()
    const channel = server.openSecureChannel(
      3600000,
      OPCUA.SecurePolicyUri.None,
      OPCUA.MessageSecurityMode.None
    )

    expect(channel).rejects.toThrowError()

    await server.disconnect()
  })

  it('Open/Close secure channel', async () => {
    const server = new UAServer(WebSockURL)
    await server.connect()
    await server.hello(EndpointURL)
    const channel = await server.openSecureChannel(
      3600000,
      OPCUA.SecurePolicyUri.None,
      OPCUA.MessageSecurityMode.None
    )

    expect(channel).to.toBeDefined()

    const closeChannel = await server.closeSecureChannel()
    expect(closeChannel).not.toBeDefined()

    await server.disconnect()
  })
})

describe('GetEndpoints', async () => {
  it('Works', async () => {
    const server = new UAServer(WebSockURL)
    await server.connect()
    await server.hello(EndpointURL)
    await server.openSecureChannel(
      3600000,
      OPCUA.SecurePolicyUri.None,
      OPCUA.MessageSecurityMode.None
    )

    const endpoints = await server.getEndpoints()
    expect(endpoints).to.toBeDefined()

    await server.closeSecureChannel()
    await server.disconnect()
  })

  it('Open Secure Channel all modes', async () => {
    const server = new UAServer(WebSockURL)
    await server.connect()
    await server.hello(EndpointURL)
    await server.openSecureChannel(
      3600000,
      OPCUA.SecurePolicyUri.None,
      OPCUA.MessageSecurityMode.None
    )
    const resp: any = await server.getEndpoints()
    await server.closeSecureChannel()
    await server.disconnect()

    for (let i = 0; i < resp.Endpoints.length; i++) {
      const endpoint: any = resp.Endpoints[i]
      if (endpoint.SecurityPolicyUri == OPCUA.SecurePolicyUri.None) continue

      it(
        'Can connect to: ' + endpoint.SecurityPolicyUri + ' mode ' + endpoint.SecurityMode,
        async () => {
          const server = new UAServer(WebSockURL)
          await server.connect()
          await server.hello(EndpointURL)

          const channel = await server.openSecureChannel(
            3600000,
            endpoint.SecurityPolicyUri,
            endpoint.SecurityMode,
            endpoint.ServerCertificate
          )

          expect(channel).to.toBeDefined()
          await server.closeSecureChannel()
          await server.disconnect()
        }
      )
    }
  })
})

describe('Session', async () => {
  let server: UAServer
  beforeEach(async () => {
    server = new UAServer(WebSockURL)
    await server.connect()
    await server.hello(EndpointURL)
    await server.openSecureChannel(
      3600000,
      OPCUA.SecurePolicyUri.None,
      OPCUA.MessageSecurityMode.None
    )
  })

  afterEach(async () => {
    await server.closeSecureChannel()
    await server.disconnect()
  })

  it('CreateSession', async () => {
    const session = await server.createSession('test_js_session', 3600000)
    expect(session).to.toBeDefined()

    const closedSession = await server.closeSession()
    expect(closedSession).to.toBeDefined()
  })
})

describe('Authentication', async () => {
  let server: UAServer
  let basic128Rsa15Edpoint: any

  beforeEach(async () => {
    server = new UAServer(WebSockURL)
    await server.connect()
    await server.hello(EndpointURL)
    await server.openSecureChannel(
      3600000,
      OPCUA.SecurePolicyUri.None,
      OPCUA.MessageSecurityMode.None
    )
    const session: any = await server.createSession('test_js_session', 3600000)
    for (const endpoint of session.ServerEndpoints) {
      if (endpoint.SecurityPolicyUri == OPCUA.SecurePolicyUri.Basic128Rsa15) {
        basic128Rsa15Edpoint = endpoint
        return
      }
    }
  })

  afterEach(async () => {
    await server.closeSession()
    await server.closeSecureChannel()
    await server.disconnect()
  })

  it('Anonymous', async () => {
    let anonymousPolicyId: string = ''
    for (const tokenPolicy of basic128Rsa15Edpoint.UserIdentityTokens) {
      if (tokenPolicy.TokenType == OPCUA.UserTokenType.Anonymous) {
        anonymousPolicyId = tokenPolicy.PolicyId
      }
    }

    expect(anonymousPolicyId).not.toEqual('')
    const session = await server.activateSession(anonymousPolicyId)
    expect(session).to.toBeDefined()
  })

  it('Username', async () => {
    let usernamePolicyId: string = ''
    for (const tokenPolicy of basic128Rsa15Edpoint.UserIdentityTokens) {
      if (tokenPolicy.TokenType == OPCUA.UserTokenType.UserName) {
        usernamePolicyId = tokenPolicy.PolicyId
        break
      }
    }

    expect(usernamePolicyId).not.toEqual('')
    const session = await server.activateSession(usernamePolicyId, 'admin', '12345')
    expect(session).to.toBeDefined()
  })

  it('Username Invalid', async () => {
    let usernamePolicyId: string = ''
    for (const tokenPolicy of basic128Rsa15Edpoint.UserIdentityTokens) {
      if (tokenPolicy.TokenType == OPCUA.UserTokenType.UserName) {
        usernamePolicyId = tokenPolicy.PolicyId
        break
      }
    }

    expect(usernamePolicyId).not.toEqual('')
    try {
      await server.activateSession(usernamePolicyId, 'admin', 'hahaha')
      expect(true).to.toEqual(false)
    } catch (e) {
      expect(e).to.toEqual(Error('2149515264'))
    }
  })

  it('Username password null', async () => {
    let usernamePolicyId: string = ''
    for (const tokenPolicy of basic128Rsa15Edpoint.UserIdentityTokens) {
      if (tokenPolicy.TokenType == OPCUA.UserTokenType.UserName) {
        usernamePolicyId = tokenPolicy.PolicyId
        break
      }
    }

    expect(usernamePolicyId).not.toEqual('')
    try {
      await server.activateSession(usernamePolicyId, 'admin')
      expect(true).to.toEqual(false)
    } catch (e) {
      expect(e).to.toEqual(Error('2149580800'))
    }
  })

  it('Certificate', async () => {
    let certificatePolicyId: string = ''
    for (const tokenPolicy of basic128Rsa15Edpoint.UserIdentityTokens) {
      if (tokenPolicy.TokenType == OPCUA.UserTokenType.Certificate) {
        certificatePolicyId = tokenPolicy.PolicyId
        break
      }
    }

    expect(certificatePolicyId).not.toEqual('')

    // Certificate and private key of user 'admin'
    const userCert = `
        -----BEGIN CERTIFICATE-----
        MIID2zCCAsOgAwIBAgIJAKB2iVVea0fRMA0GCSqGSIb3DQEBCwUAMEkxCzAJBgNV
        BAYTAlVTMQswCQYDVQQIDAJUWDEQMA4GA1UEBwwHSG91c3RvbjELMAkGA1UECgwC
        QUwxDjAMBgNVBAMMBWFkbWluMB4XDTIzMDExMTIxMjIzNloXDTI0MDExMTIxMjIz
        NlowSTELMAkGA1UEBhMCVVMxCzAJBgNVBAgMAlRYMRAwDgYDVQQHDAdIb3VzdG9u
        MQswCQYDVQQKDAJBTDEOMAwGA1UEAwwFYWRtaW4wggEiMA0GCSqGSIb3DQEBAQUA
        A4IBDwAwggEKAoIBAQCoa4EvEHPNZq3vZHktcVcjiXGMgkvJxKHLg1MAzNJJq0Ci
        dXwx9yDckAdnQUaBHnmUJmzvzgwGkxU5bHU/HKQbcOrNcS+WV88Y0gNvVk1J8wnl
        alCVVqCl3Wroq4c47X7CBl5YceKolUfXUmvgcX0puObBW3jKQN2iKO+B5NsbxQJY
        eYWpftpDngEAl7sdSr7CoraejZfX+9VC6qGshuh+mZyxWmGh0vWOYNM0bmzN5UW2
        hMbIdGJaotIwHiZU8FXXLiyJS4vXtLpFMH8D1cb0cswidDSmPWCstnVpgHuSiGSX
        ahpfP7TM/XJ+QaUFhPQfASoB6vdT9dHnqysB9RYBAgMBAAGjgcUwgcIwCQYDVR0T
        BAIwADARBglghkgBhvhCAQEEBAMCBsAwCwYDVR0PBAQDAgL0MBMGA1UdJQQMMAoG
        CCsGAQUFBwMCMB8GCWCGSAGG+EIBDQQSFhBBZG1pbiBPUENVQSBDZXJ0MB0GA1Ud
        DgQWBBRc+jU5dVRx7HJxqnJsy1xHnMoWLzAfBgNVHSMEGDAWgBRc+jU5dVRx7HJx
        qnJsy1xHnMoWLzAfBgNVHREEGDAWhhR1cm46b3BjdWE6dXNlcjphZG1pbjANBgkq
        hkiG9w0BAQsFAAOCAQEAl6gZp1tpJcQ/nr9Sow4k0Zv5ooXRy+tQRFrp/H0VJ+cR
        PioBxgyUQDBcDhjiZUCWIcG3vd/ps++P6MNrgQqx2JTLIskF/Hl4r3bTSgub06Q/
        +T8OQMYI/wvDicnv7CMZLed0gS23A5/9o9C5B/Gy3kBEJ/hKlRHhPHPoB3/a2nR5
        RF6Zia574MlbadyL3e16CUDLvu/wb48QG6pdz015YCrzuhOxfi/IAxPsCHN0x+bF
        dpzk3rnEL6q+Mrl2a/iT6dgH5HfRnt3SW6u1MFf9wnZWB3yYHoPCl2/MkDerl9hI
        5u7yFRlWWqWhHShKfrPsd8WXzfd+oGLMp/zi+db51A==
        -----END CERTIFICATE-----
      `
    const result = await server.activateSession(certificatePolicyId, userCert)
    expect(result).to.toBeDefined()
  })
})
