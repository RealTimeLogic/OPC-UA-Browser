import { UaClient, TransportProfile, CreateSessionData, ActivateSessionData, FindServersData, GetEndpointsData, ReadData, BrowseData, UserTokenPolicy } from "opcua-client"

type Request = {
  reject(error: unknown): void
  resolve(msg: unknown): void
  id: number
  timeout: NodeJS.Timeout
}

export class RtlProxyClient implements UaClient {
  private Requests: Map<number, Request> = new Map()
  private RequestCounter: number = 0
  private WebSock: WebSocket | null = null
  private readonly SiteURL: string
  private readonly disconnectCallback?: (e: Error) => void

  constructor(siteURL: string, disconnectCallback?: (e: Error) => void) {
    this.SiteURL = siteURL
    this.disconnectCallback = disconnectCallback
  }

  private _reset(e: Error) {
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

      this.WebSock.onerror = (e: Event) => {
        console.error('Websocket ' + this.SiteURL + 'error: ' + e)
        this._reset(new Error('socket disconnected'))
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
          throw new Error('Invalid JSON response: ' + e + ' ' + msg.data)
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

  private async sendRequest(r: unknown) {
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
      const request = r as Request
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

  public async hello(endpointUrl: string, transportProfileUri: string | null = null): Promise<void> {
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

    return this.sendRequest(request) as Promise<void>
  }

  public async openSecureChannel (timeoutMs: number, securityPolicyUri: string, securityMode: number, serverCertificate?: string | Uint8Array | File | null): Promise<void>
  {
    const request = {
      OpenSecureChannel: {
        TimeoutMs: timeoutMs,
        SecurityPolicyUri: securityPolicyUri,
        SecurityMode: securityMode,
        ServerCertificate: serverCertificate
      }
    }
    return this.sendRequest(request) as Promise<void>
  }

  public async closeSecureChannel(): Promise<void> {
    const request = {
      CloseSecureChannel: {}
    }

    return this.sendRequest(request) as Promise<void>
  }

  public async createSession(sessionName: string, timeoutMs: number): Promise<CreateSessionData> {
    const request = {
      CreateSession: {
        SessionName: sessionName,
        SessionTimeout: timeoutMs
      }
    }
    return this.sendRequest(request) as Promise<CreateSessionData>
  }

  public async activateSession(tokenPolicy: UserTokenPolicy, identity?: string, secret?: string): Promise<ActivateSessionData> {
    const request = {
      ActivateSession: {
        TokenType: tokenPolicy.TokenType,
        PolicyId: tokenPolicy.PolicyId,
        Secret: secret,
        Identity: identity
      }
    }

    return this.sendRequest(request) as Promise<ActivateSessionData>
  }

  public async closeSession(): Promise<void> {
    const request = {
      CloseSession: {}
    }
    return this.sendRequest(request) as Promise<void>
  }

  public async findServers(endpointUrl?: string, serverUris?: string[]): Promise<FindServersData> {

    const request = {
      FindServers: {
        EndpointUrl: endpointUrl,
        ServerUris: serverUris
      }
    }

    return this.sendRequest(request) as Promise<FindServersData>
  }

  public async getEndpoints(endpointUrl?: string): Promise<GetEndpointsData> {
    const request = {
      GetEndpoints: {
        EndpointUrl: endpointUrl
      }
    }

    return this.sendRequest(request) as Promise<GetEndpointsData>
  }

  public async browse(nodeId: string): Promise<BrowseData> {
    const request = {
      Browse: {
        NodeId: nodeId.toString()
      }
    }
    return this.sendRequest(request) as Promise<BrowseData>
  }

  public async read(nodeId: string | string[]): Promise<ReadData> {
    const request = {
      Read: {
        NodeId: nodeId.toString()
      }
    }
    return this.sendRequest(request) as Promise<ReadData>
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
