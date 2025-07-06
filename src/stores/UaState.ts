import { defineStore } from 'pinia'
import { computed, ref } from 'vue'
import { createUaClient } from '../utils/ua_client_proxy'
import * as OPCUA from "opcua-client"

export type AttributeValueType = {
  name: string
  attributeId: OPCUA.AttributeIds
  value: OPCUA.DataValue
}

export type NodeType = {
  nodeid: OPCUA.NodeId
  label: string
  nodes: NodeType[]
}

export enum LogMessageType {
  Info = 'info',
  Error = 'error'
}

export type LogEntryType = {
  time: Date
  type: LogMessageType
  details: string
}

export type UaStateType = {
  server: OPCUA.UaClient | undefined
  webSockURL: string
  root: NodeType
  needAuth: boolean
  messages: LogEntryType[]
}

export type Credentials = {
  TokenPolicy: OPCUA.UserTokenPolicy
  Identity: string | File | undefined
  Secret: string | undefined
}

export type ConnectionParams = {
  EndpointUrl: string
  TransportProfileUri: string
  SecurityPolicyUri: string
  SecurityMode: number
  ServerCertificate: Uint8Array | null
  Token: Credentials
}

function opcuaWebSockURL(): string {
  // when we a in defelopment mode then
  // web page is running inside vite dev server
  // and the same time backed is running with mako: mako in linux usually
  // runs on port 9357 and in windows on port 80
  // if you have different ports then fix following URIes
  if (process.env.NODE_ENV === 'development') {
    const platform = navigator.userAgent.toLocaleLowerCase()
    if (platform.indexOf("linux") >= 0) {
      return 'ws://localhost:9357/opcua_client.lsp'
    } else if (platform.indexOf("windows") >= 0){
      return 'ws://localhost/opcua_client.lsp'
    }
  }

  const pos = window.location.pathname.lastIndexOf('/')
  const basePath = window.location.pathname.substring(0, pos)
  const host = window.location.hostname
  const protocol = window.location.protocol.replace("http", "ws")
  const port = window.location.port
  return `${protocol}//${host}${port ? ':'+port: ''}${basePath}/opcua_client.lsp`
}

export const uaApplication = defineStore('uaApplication', () => {
  const server = ref<OPCUA.UaClient | undefined>(undefined)

  const needAuth = ref(false)
  const root = ref<NodeType>({
    nodeid: new OPCUA.NodeId('i=84'),
    label: 'RootFolder',
    nodes: []
  })

  const messagesLog = ref<LogEntryType[]>([])

  const messages = computed(() => messagesLog.value.reverse())

  function onMessage(type: LogMessageType, e: Error | string) {
    const msg = e instanceof Error ? e.message : e

    messagesLog.value.push({
      time: new Date(),
      type: type,
      details: msg
    })
  }

  const connected = computed(() => server.value != undefined)

  async function connect(endpoint: ConnectionParams) {
    try {
      const srv = createUaClient(endpoint.EndpointUrl, uaApplication().opcuaWebSockURL())

      onMessage(LogMessageType.Info, 'Connecting to endpoint ' + endpoint.EndpointUrl + ' with profile ' + endpoint.TransportProfileUri)
      await srv.hello(endpoint.EndpointUrl, endpoint.TransportProfileUri)

      onMessage(LogMessageType.Info, 'Opening secure channel')
      await srv.openSecureChannel(
        360000,
        endpoint.SecurityPolicyUri,
        endpoint.SecurityMode,
        endpoint.ServerCertificate
      )

      onMessage(LogMessageType.Info, 'Creating session')
      await srv.createSession('opcua web session', 3600000)

      onMessage(LogMessageType.Info, 'Logging to OPCUA server:' + endpoint.Token.Identity + ' with policy ' + endpoint.Token.TokenPolicy.PolicyId)
      await srv.activateSession(
        endpoint.Token.TokenPolicy,
        endpoint.Token.Identity,
        endpoint.Token.Secret
      )

      onMessage(LogMessageType.Info, 'Connected to OPCUA server')
      server.value = srv
      root.value.nodes = []
    } catch (e: unknown) {
      onMessage(LogMessageType.Error, e instanceof Error ? e.message : String(e))
    }
  }

  async function browse(node: NodeType) {
    try {
      if (server.value == undefined) {
        return
      }

      if (node.nodes.length != 0) {
        node.nodes = []
        return
      }

      onMessage(LogMessageType.Info, 'Browsing nodeID ' + node.nodeid)
      const resp: OPCUA.BrowseData = await server.value.browse(node.nodeid.toString())
      resp.Results.forEach((result: OPCUA.BrowseResult) => {
          if (!Array.isArray(result.References))
            return

          result.References.forEach((ref: OPCUA.ReferenceDescription) => {
            node.nodes.push({
              nodeid: ref.NodeId,
              label: ref.BrowseName.Name ?? '',
              nodes: []
            })
        })
      })
    } catch (e: unknown) {
      onMessage(LogMessageType.Error, e instanceof Error ? e.message : String(e))
    }
  }

  async function readAttributes(nodeId: string): Promise<AttributeValueType[] | undefined> {
    try {
      if (server.value == undefined) {
        return
      }

      onMessage(LogMessageType.Info, 'Reading attributes ' + nodeId)
      const resp: OPCUA.ReadData = await server.value.read(nodeId)
      const attributes: AttributeValueType[] = []
      resp.Results.forEach((r: OPCUA.DataValue, index: number) => {
        if (r.StatusCode && r.StatusCode.Code !== 0)
          return

        attributes.push({
          name: OPCUA.getAttributeName(index),
          attributeId: index,
          value: r
        })
      })

      return attributes
    } catch (e: unknown) {
      onMessage(LogMessageType.Error, e instanceof Error ? e.message : String(e))
    }
  }

  return {
    server,
    opcuaWebSockURL,
    root,
    needAuth,
    messages,
    connected,
    connect,
    browse,
    readAttributes,
    onMessage
  }
})
