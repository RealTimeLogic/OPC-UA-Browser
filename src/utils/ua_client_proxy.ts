import { UaClient, TransportProfile } from "opcua-client"

type Request = {
  reject(error: any): void
  resolve(msg: any): void
  id: number
  timeout: any
}

export class RtlProxyClient implements UaClient {
  private Requests: Map<number, Request> = new Map()
  private RequestCounter: number = 0
  private WebSock: WebSocket | null = null
  private readonly SiteURL: string
  private readonly disconnectCallback?: any

  constructor(siteURL: string, disconnectCallback?: any) {
    this.SiteURL = siteURL
    this.disconnectCallback = disconnectCallback
  }

  private _reset(e: any) {
    for (const request of this.Requests.entries()) {
      const val = request[1]
      val.reject(e)
    }
    this.WebSock = null
    this.Requests = new Map()
    if (this.disconnectCallback != null)
      return this.disconnectCallback(e)
  }

  private async connectWebSocket() {
    return new Promise((resolve, reject) => {
      if (this.WebSock != undefined) {
        reject(new Error('already connected'))
        return
      }

      this.WebSock = new WebSocket(this.SiteURL)
      this.WebSock.onopen = () => {
        resolve(this)
      }

      this.WebSock.onclose = () => {
        this._reset(new Error('socket disconnected'))
        reject(new Error('socket disconnected'))
      }

      this.WebSock.onerror = (e) => {
        console.error('Websocket ' + this.SiteURL + 'error: ' + e)
        this._reset(e)
        reject(new Error('socket disconnected'))
      }

      this.WebSock.onmessage = (msg) => {
        try {
          const resp = JSON.parse(msg.data)
          const request = this.Requests.get(resp.id)
          if (!request) return
          if (resp.Error) {
            request.reject(new Error(resp.Error))
          } else {
            clearTimeout(request.timeout)
            this.Requests.delete(resp.id)
            request.resolve(resp.Data)
          }
        } catch(e) {
          throw new Error('Invalid JSON response: ' + msg.data)
        }
      }
    })
  }

  private async disconnectWebSocket() {
    return new Promise((resolve, reject) => {
      if (this.WebSock != undefined) {
        this.WebSock.close()
        this.WebSock = null
        resolve(this)
      } else {
        reject(new Error('already disconnected'))
      }
    })
  }

  private nextRequestId() {
    this.RequestCounter += 1
    return this.RequestCounter
  }

  private async sendRequest(request: any) {
    return new Promise((resolve, reject) => {
      if (this.WebSock == null) {
        reject(new Error('No connection to web socket server.'))
        return
      }

      const requestId = this.nextRequestId()
      const requestData: Request = {
        id: requestId,
        resolve: resolve,
        reject: reject,
        timeout: setTimeout(() => {
          reject('timeout')
        }, 30000)
      }

      this.Requests.set(requestId, requestData)
      request.id = requestId

      const msg = JSON.stringify(request)
      this.WebSock.send(msg)
    })
  }

  async connect() {
    return this.connectWebSocket()
  }

  async disconnect() {
    return this.disconnectWebSocket()
  }

  public async hello(endpointUrl: string, transportProfileUri: string | null = null) {
    if (this.WebSock == null)
      await this.connectWebSocket()

    if (transportProfileUri == null) {
      if (endpointUrl.startsWith("opc.tcp://")) {
        // opc.tcp:// is only binary
        transportProfileUri = TransportProfile.TcpBinary
      }
      else if (endpointUrl.includes("https://") || endpointUrl.includes("http://")) {
        // Json encoding over HTTP is supported only by RealTimelogic
        // Use only binary ro be able to connect to any OPCUA server
        // After requesting all Endpoints user could select Realtime logic OPCUA server with JSON ecoding
        transportProfileUri = TransportProfile.HttpsBinary
      }
      else {
        throw new Error('Unknown transport profile: ' + transportProfileUri)
      }
    }

    const request = {
      ConnectEndpoint: {
        EndpointUrl: endpointUrl,
        TransportProfileUri: transportProfileUri
      }
    }

    return this.sendRequest(request)
  }

  public async openSecureChannel(
    timeoutMs: number,
    securityPolicyUri: string,
    securityMode: number,
    serverCertificate: string | null = null
  ) {
    const request = {
      OpenSecureChannel: {
        TimeoutMs: timeoutMs,
        SecurityPolicyUri: securityPolicyUri,
        SecurityMode: securityMode,
        ServerCertificate: serverCertificate
      }
    }
    return this.sendRequest(request)
  }

  async closeSecureChannel() {
    const request = {
      CloseSecureChannel: {}
    }

    return this.sendRequest(request)
  }

  async createSession(sessionName: string, timeoutMs: number) {
    const request = {
      CreateSession: {
        SessionName: sessionName,
        SessionTimeout: timeoutMs
      }
    }
    return this.sendRequest(request)
  }

  async activateSession(tokenPolicy: any, identity?: string, secret?: string) {
    const request = {
      ActivateSession: {
        TokenType: tokenPolicy.TokenType,
        PolicyId: tokenPolicy.PolicyId,
        Secret: secret,
        Identity: identity
      }
    }

    return this.sendRequest(request)
  }

  async closeSession() {
    const request = {
      CloseSession: {}
    }
    return this.sendRequest(request)
  }

  async findServers(endpointUrl?: string, serverUris?: string[])  {

    const request = {
      FindServers: {
        EndpointUrl: endpointUrl,
        ServerUris: serverUris
      }
    }

    return this.sendRequest(request)
  }

  async getEndpoints(endpointUrl?: string) {
    const request = {
      GetEndpoints: {
        EndpointUrl: endpointUrl
      }
    }

    return this.sendRequest(request)
  }

  async browse(nodeId: string): Promise<any> {
    const request = {
      Browse: {
        NodeId: nodeId.toString()
      }
    }
    return this.sendRequest(request)
  }

  async read(nodeId: string | string[]) {
    const request = {
      Read: {
        NodeId: nodeId.toString()
      }
    }
    return this.sendRequest(request)
  }
}

import { UaHttpClient } from "opcua-client"

export function createUaClient(endpointUrl: string, wsUrl: string): UaClient {
  const endpoint = new URL(endpointUrl.replace("opc.http://", "http://").replace("opc.https://", "https://"))
  let srv: UaClient
  console.log(`window.location.origin: ${window.location.origin} endpoint.origin: ${endpoint.origin} endpointUrl: ${endpointUrl} wsUrl: ${wsUrl} endpoint: $`)
  if (endpointUrl.startsWith("opc.tcp://") || window.location.origin !== endpoint.origin) {
    console.log('Using RtlProxyClient for ' + wsUrl)
    srv = new RtlProxyClient(wsUrl)
  } else {
    console.log('Using direct HTTP connection')
    srv = new UaHttpClient()
  }

  return srv
}
