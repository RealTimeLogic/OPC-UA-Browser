"use strict";

const attributeNames = [
    "NodeId",
    "NodeClass",
    "BrowseName",
    "DisplayName",
    "Description",
    "WriteMask",
    "UserWriteMask",
    "IsAbstract",
    "Symmetric",
    "InverseName",
    "ContainsNoLoops",
    "EventNotifier",
    "Value",
    "DataType",
    "ValueRank",
    "ArrayDimensions",
    "AccessLevel",
    "UserAccessLevel",
    "MinimumSamplingInterval",
    "Historizing",
    "Executable",
    "UserExecutable",
    "DataTypeDefinition",
    "RolePermissions",
    "UserRolePermissions",
    "AccessRestrictions",
    "AccessLevelEx",
]

const OPCUA = {
  SecurePolicyUri: {
    None: "http://opcfoundation.org/UA/SecurityPolicy#None",
    Basic128Rsa15: "http://opcfoundation.org/UA/SecurityPolicy#Basic128Rsa15",
    Basic256: "http://opcfoundation.org/UA/SecurityPolicy#Basic256",
    Basic256Sha256: "http://opcfoundation.org/UA/SecurityPolicy#Basic256Sha256",
    Aes128Sha256RsaOaep: "http://opcfoundation.org/UA/SecurityPolicy#Aes128_Sha256_RsaOaep",
    Aes256Sha256RsaPss: "http://opcfoundation.org/UA/SecurityPolicy#Aes256_Sha256_RsaPss"
  },

  TransportProfile: {
    Binary: "http://opcfoundation.org/UA-Profile/Transport/uatcp-uasc-uabinary"
  },

  MessageSecurityMode: {
    None: 1,
    Sign: 2,
    SignAndEncrypt: 3
  },

  UserTokenType: {
    Anonymous: 0,
    UserName: 1,
    Certificate: 2,
    IssuedToken: 3
  }
}

type Request = {
  reject(error: any): void;
  resolve(msg: any): void;
  id: number;
  timeout: any;
}

class UAServer {
  Requests: Map<number, Request> = new Map();
  RequestCounter: number = 0
  WebSock?: WebSocket
  readonly SiteURL: string
  disconnectCallback: any

  constructor(siteURL: string) {
    this.SiteURL = siteURL
  }
  
  _reset(e: any) {
    for (const request of this.Requests.entries()) {
      const val = request[1]
      val.reject(e);
    }
    this.WebSock = undefined
    this.Requests = new Map()
    if (this.disconnectCallback != null)
      return this.disconnectCallback(e)
  }

  async connectWebSocket(disconnectCallback: any = null) {
    return new Promise((resolve, reject) => {
      if (this.WebSock != undefined)
      {
        reject(new Error("already connected"))
        return 
      }

      this.disconnectCallback = disconnectCallback
      this.WebSock = new WebSocket(this.SiteURL);
      this.WebSock.onopen = () => {
        console.log("Connected to websocket " + this.SiteURL);
        resolve(this)
      }

      this.WebSock.onclose = () => {
        console.log("Disconnected websocket " + this.SiteURL);
        this._reset(new Error("socket disconnected"));
        reject(new Error("socket disconnected"))
      }

      this.WebSock.onerror = (e) => {
        console.log("Websocket " + this.SiteURL + "error: " + e);
        this._reset(e);
        reject(e)
      }

      this.WebSock.onmessage = (msg) => {
        const resp = JSON.parse(msg.data)
        const request = this.Requests.get(resp.id);
        if (!request)
          return;
        if (resp.error) {
            request.reject(new Error(resp.error));
        }
        else {
            clearTimeout(request.timeout)
            this.Requests.delete(resp.id)
            request.resolve(resp.data);
        }
      }
    })
  }

  async disconnectWebSocket() {
    return new Promise ((resolve, reject) => {
      if (this.WebSock != undefined) {
        this.WebSock.close()
        this.WebSock = undefined
        resolve(this);
      } else {
        reject(new Error("already disconnected"))
      }
    })
  }

  nextRequestId() {
      this.RequestCounter += 1
      return this.RequestCounter
  }

  sendRequest(request: any) {
    return new Promise((resolve, reject) => {
      if (this.WebSock == undefined){
        reject(new Error("No connection to web socket server."))
        return;
      }

      const requestId = this.nextRequestId()
      const requestData: Request = {
        id: requestId,
        resolve: resolve,
        reject: reject,
        timeout: setTimeout(() => {reject("timeout")}, 30000)
      }

      this.Requests.set(requestId, requestData)
      request.id = requestId

      const msg = JSON.stringify(request)
      this.WebSock.send(msg)
    });
  }

  hello(endpointUrl: string){
    const config = {
      endpointUrl: endpointUrl
    }

    const request = {
        connectEndpoint: config
    }

    return this.sendRequest(request)
  }

  openSecureChannel(timeoutMs: number, securityPolicyUri: string, securityMode: number, serverCertificate: string | null = null) {
    const request = {
      openSecureChannel: {
        timeoutMs: timeoutMs,
        securityPolicyUri: securityPolicyUri,
        securityMode: securityMode,
        serverCertificate: serverCertificate
      }
    }
    return this.sendRequest(request)
  }

  closeSecureChannel() {
    const request = {
      closeSecureChannel: {}
    }
    return this.sendRequest(request)
  }


  createSession(sessionName: string, timeoutMs: number) {
    const request = {
      createSession: {
        sessionName: sessionName,
        sessionTimeout: timeoutMs
      }
    }
    return this.sendRequest(request)
  }

  activateSession(policyId: string, identity: string | undefined = undefined, secret: string | undefined = undefined) {
    if (secret == undefined) {
      secret = identity
      identity = undefined
    }

    const request = {
      activateSession: {
        policyId: policyId,
        secret: secret,
        identity: identity
      }
    }

    return this.sendRequest(request)
  }

  closeSession() {
    const request = {
      closeSession: {}
    }
    return this.sendRequest(request)
  }

  getEndpoints() {
    const request = {
      getEndpoints: {}
    }
    return this.sendRequest(request)
  }

  browse(nodeId: string) {
    const request = {
        browse: {
            nodeId: nodeId
        }
    }
    return this.sendRequest(request)
  }

  read(nodeId: string){
    const request = {
        read: {
            nodeId: nodeId
        }
    }
    return this.sendRequest(request)
  }

  getAttributeName(attrId: number): string {
    return attributeNames[attrId]
  }

  getPolicyUri(name: string): string {
    switch (name) {
      case "Basic128Rsa15": 
        return "http://opcfoundation.org/UA/SecurityPolicy#Basic128Rsa15"

      case "Basic256":
        return "http://opcfoundation.org/UA/SecurityPolicy#Basic256"

      case "Basic256Sha256":
        return "http://opcfoundation.org/UA/SecurityPolicy#Basic256Sha256"
      
      case "None":
        return "http://opcfoundation.org/UA/SecurityPolicy#None"

        case "Aes128_Sha256_RsaOaep":
        return "http://opcfoundation.org/UA/SecurityPolicy#Aes128_Sha256_RsaOaep"

        case "Aes256_Sha256_RsaPss":
        return "http://opcfoundation.org/UA/SecurityPolicy#Aes256_Sha256_RsaPss"
    }

    throw Error("Invalid security policy name '" + name + "'");
  }

  getPolicyName(uri: string): string {
    switch (uri) {
      case "http://opcfoundation.org/UA/SecurityPolicy#Basic128Rsa15": 
        return "Basic128Rsa15"

      case "http://opcfoundation.org/UA/SecurityPolicy#Basic256":  
        return "Basic256"

      case "http://opcfoundation.org/UA/SecurityPolicy#Basic256Sha256": 
        return "Basic256Sha256";
      
      case "http://opcfoundation.org/UA/SecurityPolicy#None":
        return "None"

        case "http://opcfoundation.org/UA/SecurityPolicy#Aes128_Sha256_RsaOaep":
        return "Aes128_Sha256_RsaOaep"

        case "http://opcfoundation.org/UA/SecurityPolicy#Aes256_Sha256_RsaPss":
        return "Aes256_Sha256_RsaPss"
    }

    return uri;
  }

  getMessageModeName(mode: number) {
    switch(mode)
    {
      case 1: return "None";
      case 2: return "Sign";
      case 3: return "SignAndEncrypt";
      default: return mode
    }
  }
}

export { UAServer, OPCUA}
