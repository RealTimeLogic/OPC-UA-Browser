import { describe, it, expect, beforeEach, afterEach } from 'vitest'

import {UAServer, OPCUA} from '../ua_server'

const WebSockURL = "ws://localhost/opcua_client.lsp"
const EndpointURL = "opc.tcp://localhost:4841"

describe('Websocket connecting', async () => {
  it('Connects to websocket', async () => {
    const server = new UAServer(WebSockURL)
    const connectResult = await server.connectWebSocket()
    expect(connectResult).to.equal(server)

    const disconnectResult = await server.disconnectWebSocket()
    expect(disconnectResult).to.equal(server)
  })

  it('second connect not possible', async () => {
    const server = new UAServer(WebSockURL)
    const connectResult = await server.connectWebSocket()
    expect(connectResult).to.equal(server)

    await expect(server.connectWebSocket()).rejects.toThrowError(new Error("already connected"))

    const disconnectResult = await server.disconnectWebSocket()
    expect(disconnectResult).to.equal(server)
  })

  it('second disconnect not possible', async () => {
    const server = new UAServer(WebSockURL)
    await server.connectWebSocket()
    await server.disconnectWebSocket()
    await expect(server.disconnectWebSocket()).rejects.toThrowError(new Error("already disconnected"))
  })

  it('Disconnect callback called', async () => {
    const server = new UAServer(WebSockURL)

    let error = undefined
    const onDisconnect = (e: Error) => {
      error = e
    }
    
    const connectResult = await server.connectWebSocket(onDisconnect)
    expect(connectResult).to.equal(server)

    server.WebSock?.close();
    
    expect(error).not.toEqual(null)
  })
})

describe("Connect to OPCUA endpoint", async ()=> {
  let server: UAServer

  beforeEach(async () => {
    server = new UAServer(WebSockURL)
    await server.connectWebSocket()
  })

  afterEach(async () => {
    await server.disconnectWebSocket()
  })

  it("Connect/disconnect OPCUA server", async () => {
    const opening = await server.hello(EndpointURL)
    expect(opening).not.to.toBeDefined()
  } )

  it("Fails to connect to unavailable server", async () => {
    // Add a number to port
    expect(server.hello(EndpointURL + "2")).rejects.toThrowError()
  } )
})

describe("OpenSecureChannel SecurePolicy None", async ()=> {
  it("OpenSecure channel without connect", async () => {
    const server = new UAServer(WebSockURL)
    await server.connectWebSocket()
    const channel = server.openSecureChannel(3600000, OPCUA.SecurePolicyUri.None, OPCUA.MessageSecurityMode.None)

    expect(channel).rejects.toThrowError()

    await server.disconnectWebSocket()
  } )

  it("Open/Close secure channel", async () => {
    const server = new UAServer(WebSockURL)
    await server.connectWebSocket()
    await server.hello(EndpointURL)
    const channel = await server.openSecureChannel(3600000, OPCUA.SecurePolicyUri.None, OPCUA.MessageSecurityMode.None)

    expect(channel).to.toBeDefined()

    const closeChannel = await server.closeSecureChannel()
    expect(closeChannel).not.toBeDefined()

    await server.disconnectWebSocket()
  } )
})

describe("GetEndpoints", async ()=>{
  it("Works", async () => {
    const server = new UAServer(WebSockURL)
    await server.connectWebSocket()
    await server.hello(EndpointURL)
    await server.openSecureChannel(3600000, OPCUA.SecurePolicyUri.None, OPCUA.MessageSecurityMode.None)

    const endpoints = await server.getEndpoints()
    expect(endpoints).to.toBeDefined()

    await server.closeSecureChannel()
    await server.disconnectWebSocket()
  } )

  it("Open Secure Channel all modes", async () => {
    const server = new UAServer(WebSockURL)
    await server.connectWebSocket()
    await server.hello(EndpointURL)
    await server.openSecureChannel(3600000, OPCUA.SecurePolicyUri.None, OPCUA.MessageSecurityMode.None)
    const resp: any = await server.getEndpoints()
    await server.closeSecureChannel()
    await server.disconnectWebSocket()

    for (let i = 0; i < resp.endpoints.length; i++) {
      const endpoint: any = resp.endpoints[i]
      if (endpoint.securityPolicyUri == OPCUA.SecurePolicyUri.None)
        continue

      it ("Can connect to: " + endpoint.securityPolicyUri + " mode "+ endpoint.securityMode, async () => {
        const server = new UAServer(WebSockURL)
        await server.connectWebSocket()
        await server.hello(EndpointURL)

        const channel = await server.openSecureChannel(3600000, endpoint.securityPolicyUri, endpoint.securityMode, endpoint.serverCertificate)

        expect(channel).to.toBeDefined()
        await server.closeSecureChannel()
        await server.disconnectWebSocket()
      })
    };
  })
})

describe("Session", async () => {
  let server: UAServer
  beforeEach(async () =>{
    server = new UAServer(WebSockURL)
    await server.connectWebSocket()
    await server.hello(EndpointURL)
    await server.openSecureChannel(3600000, OPCUA.SecurePolicyUri.None, OPCUA.MessageSecurityMode.None)
  })

  afterEach(async () => {
    await server.closeSecureChannel()
    await server.disconnectWebSocket()
  })

  it("CreateSession", async () =>{
    const session = await server.createSession("test_js_session", 3600000)
    expect(session).to.toBeDefined()

    const closedSession = await server.closeSession()
    expect(closedSession).to.toBeDefined()
  })
})

describe("Authentication", async () => {
  let server: UAServer
  let basic128Rsa15Edpoint: any

  beforeEach(async () =>{
    server = new UAServer(WebSockURL)
    await server.connectWebSocket()
    await server.hello(EndpointURL)
    await server.openSecureChannel(3600000, OPCUA.SecurePolicyUri.None, OPCUA.MessageSecurityMode.None)
    const session: any = await server.createSession("test_js_session", 3600000)
    for (const endpoint of session.serverEndpoints) {
      if (endpoint.securityPolicyUri == OPCUA.SecurePolicyUri.Basic128Rsa15) {
        basic128Rsa15Edpoint = endpoint
        return
      }
     }
  })

  afterEach(async () => {
    await server.closeSession()
    await server.closeSecureChannel()
    await server.disconnectWebSocket()
  })

  it("Anonymous", async () => {
    let anonymousPolicyId: string = ""
    for (const tokenPolicy of basic128Rsa15Edpoint.userIdentityTokens) {
      if (tokenPolicy.tokenType == OPCUA.UserTokenType.Anonymous) {
        anonymousPolicyId = tokenPolicy.policyId
      }
    }

    expect(anonymousPolicyId).not.toEqual("")
    const session = await server.activateSession(anonymousPolicyId)
    expect(session).to.toBeDefined()
  })

  it("Username", async () => {
    let usernamePolicyId: string = ""
    for (const tokenPolicy of basic128Rsa15Edpoint.userIdentityTokens) {
      if (tokenPolicy.tokenType == OPCUA.UserTokenType.UserName) {
        usernamePolicyId = tokenPolicy.policyId
        break
      }
    }

    expect(usernamePolicyId).not.toEqual("")
    const session = await server.activateSession(usernamePolicyId, "admin", "12345")
    expect(session).to.toBeDefined()
  })

  it("Username Invalid", async () => {
    let usernamePolicyId: string = ""
    for (const tokenPolicy of basic128Rsa15Edpoint.userIdentityTokens) {
      if (tokenPolicy.tokenType == OPCUA.UserTokenType.UserName) {
        usernamePolicyId = tokenPolicy.policyId
        break
      }
    }

    expect(usernamePolicyId).not.toEqual("")
    try {
      await server.activateSession(usernamePolicyId, "admin", "hahaha")
      expect(true).to.toEqual(false)
    } catch (e) {
      expect(e).to.toEqual(Error("2149515264"))
    }
  })

  it("Username password null", async () => {
    let usernamePolicyId: string = ""
    for (const tokenPolicy of basic128Rsa15Edpoint.userIdentityTokens) {
      if (tokenPolicy.tokenType == OPCUA.UserTokenType.UserName) {
        usernamePolicyId = tokenPolicy.policyId
        break
      }
    }

    expect(usernamePolicyId).not.toEqual("")
    try {
      await server.activateSession(usernamePolicyId, "admin")
      expect(true).to.toEqual(false)
    } catch (e) {
      expect(e).to.toEqual(Error("2149580800"))
    }
  })


 
    it("Certificate", async () => {
      let certificatePolicyId: string = ""
      for (const tokenPolicy of basic128Rsa15Edpoint.userIdentityTokens) {
        if (tokenPolicy.tokenType == OPCUA.UserTokenType.Certificate) {
          certificatePolicyId = tokenPolicy.policyId
          break
        }
      }
      
      expect(certificatePolicyId).not.toEqual("")

      // Certificate and private key of user 'admin'
      const userKey = `
        -----BEGIN PRIVATE KEY-----
        MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCoa4EvEHPNZq3v
        ZHktcVcjiXGMgkvJxKHLg1MAzNJJq0CidXwx9yDckAdnQUaBHnmUJmzvzgwGkxU5
        bHU/HKQbcOrNcS+WV88Y0gNvVk1J8wnlalCVVqCl3Wroq4c47X7CBl5YceKolUfX
        UmvgcX0puObBW3jKQN2iKO+B5NsbxQJYeYWpftpDngEAl7sdSr7CoraejZfX+9VC 
        6qGshuh+mZyxWmGh0vWOYNM0bmzN5UW2hMbIdGJaotIwHiZU8FXXLiyJS4vXtLpF
        MH8D1cb0cswidDSmPWCstnVpgHuSiGSXahpfP7TM/XJ+QaUFhPQfASoB6vdT9dHn
        qysB9RYBAgMBAAECggEAXJi+reGdyZBqkPPsq89k2WT3yQjaIlS5n+rT99ykwVwm
        bSuq3M3Cg4GskFiTKupWbd2yhyYB9ptnT+sRi2Fz2KJ8dfeE8mPUuRC+UrhgRggZ
        qMiLBZBbQtY5sTKdZe8tgf9+X6I9u/JXTUtDhGLhLc87D5P7FTgUotNe20u4K8uA
        mRRfStT4Fq7O4GaoJQb/2Tvbi4B2tKZwDE6+rw+CIKkFRJEuIf/iEz8Xr8npXDHi
        80XtbJuhiErrVl3GZdopb97davlb2hXLIubeOxK340r/uY8J0kNtZSOSihy6W8OB
        bSpG80wgPd94+Li0VTgOKtKly9angru1hJGVpC8kAQKBgQDa8ilUS/yeySFiN1tC
        rIXiVb/MN2SuSDTkARJezlVxqrVmE3rf6bQO+VOiFMagzyk9uLai33Ss6ytnJ8u3
        PkLZaBbJ/9cq9SP3avhfcveZfzcD3Vs6rrPal3sct0IBLByhLGTjD7HR2Zkf/lVS
        omgxmXzkEwsCqpQ39dowOjXvjQKBgQDE7E2Ez0TTfsHsbtLq8ZIgZwF18hnkLret
        JTTxfbHL+GqJgREqDUdXNrEJOydkDRdu8iWqmVxeVMcUZtYYNrsExlYKQP6PlOme
        hxt3/hq/CP4l6DuCmN0xOB+rINtR/AjicnCcgBKFqi+kLNBDvNQ1xPFI5kK3jPBv
        Mz5gtRHZRQKBgQDBINTl/7URF1d0PGIquOXMVVk+uSn9NcI50Nw0dosWHb+vD8XW
        V161yqZEFVF0LegyAopPtw5DLZn2fzsKI0hyX4einSNeSCh2qYv3HgFcC8Qqi4pa
        hBov2mkFVn1JbXC/ltpTE9gFxIx2lTEMGCgSgFKTGF0g9/iQODRDUEWdTQKBgHY/
        18Tamd/OjDCn0+vVKARhFlV3DekhzJYic4pYCj4LbB4p7N6tnptWcjSy2tKPsfSj
        X87zzK2whuNPZVyg8OjLGLuLj9E0gJz7UJlbc0An7EVjEOk5VgnKQ+oFDu5KRCOG
        yOyRU44ERht19ZHXgC7RlnpKGuIRtgdwZBK6aH9pAoGAFBNauJYNFoz8lOICp6QI
        sYndwMoEAX2uM9HiQW/ka921LEYNKtgfc5w/da7nWjdOWQvXkUIyVI5DFwX8KsUI
        TbPAzWF+kYG4DirCaJxH3/zdzlLTu10GxrOCmdVBjYQeeBlpsnUMLJjI4ahLb+VF
        quwNqE4GoZv/RVAm55HosPM=
        -----END PRIVATE KEY-----
      `

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
      const result = await server.activateSession(certificatePolicyId, userCert, userKey)
      expect(result).to.toBeDefined()
    })
})
