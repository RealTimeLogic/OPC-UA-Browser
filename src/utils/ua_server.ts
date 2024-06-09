// import { UAServer, UaHttpClient } from "opcua-client"
import { UAServer } from "opcua-client"

type Request = {
  reject(error: any): void
  resolve(msg: any): void
  id: number
  timeout: any
}

export class RtlProxyClient implements UAServer {
  private Requests: Map<number, Request> = new Map()
  private RequestCounter: number = 0
  private WebSock?: WebSocket
  readonly SiteURL: string
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
    this.WebSock = undefined
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
        this.WebSock = undefined
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
      if (this.WebSock == undefined) {
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

  async hello(endpointUrl: string, transportProfileUri?: string) {

    const request = {
      ConnectEndpoint: {
        EndpointUrl: endpointUrl,
        TransportProfileUri: transportProfileUri
      }
    }

    return this.sendRequest(request)
  }

  async openSecureChannel(
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

  async activateSession(policyId: any, identity?: string, secret?: string) {
    const request = {
      ActivateSession: {
        PolicyId: policyId,
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

export function createServer(endpointUrl: string, wsUrl: string): UAServer {
  return new RtlProxyClient(wsUrl)

  // if (endpointUrl.startsWith("opc.http://"))
  //   endpointUrl = endpointUrl.replace("opc.http", "http")

  // const endpoint = new URL(endpointUrl)
  // let srv: UAServer
  // if (endpointUrl.startsWith("opc.tcp://") || window.location.origin !== endpoint.origin)
  //   srv = new RtlProxyClient(wsUrl)
  // else
  //   srv = new UaHttpClient(endpointUrl)

  // return srv
}
