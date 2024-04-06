import { defineStore } from 'pinia'
import { computed, ref } from 'vue'
import { createServer} from '../utils/ua_server.js'
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
  server: OPCUA.UAServer | undefined
  webSockURL: string
  root: NodeType
  needAuth: boolean
  messages: LogEntryType[]
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
  const server = ref<OPCUA.UAServer | undefined>(undefined)

  const webSockURL = ref(opcuaWebSockURL())
  const needAuth = ref(false)
  const root = ref<NodeType>({
    nodeid: new OPCUA.NodeId('i=84'),
    label: 'RootFolder',
    nodes: []
  })

  const messagesLog = ref<LogEntryType[]>([])

  const messages = computed(() => messagesLog.value.reverse())

  function onMessage(type: LogMessageType, e: any) {
    let msg = e
    if (e.Error && e.Error.message) msg = e.Error.message

    messagesLog.value.push({
      time: new Date(),
      type: type,
      details: msg
    })
  }

  const connected = computed(() => server.value != undefined)

  async function connect(endpoint: any) {
    try {
      const srv = createServer(endpoint.EndpointUrl, uaApplication().opcuaWebSockURL())
      await srv.connect()

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

      onMessage(LogMessageType.Info, 'Logging to OPCUA server:' + endpoint.Token.Identity + ' with policy ' + endpoint.Token.TokenType.PolicyId)
      await srv.activateSession(
        endpoint.Token.TokenType.PolicyId,
        endpoint.Token.Identity,
        endpoint.Token.Secret
      )

      onMessage(LogMessageType.Info, 'Connected to OPCUA server')
      server.value = srv
      root.value.nodes = []
    } catch (e: any) {
      onMessage(LogMessageType.Error, e)
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
      const resp: any = await server.value.browse(node.nodeid.toString())
      resp.Results.forEach((result: any) => {
          if (!Array.isArray(result.References))
            return

          result.References.forEach((ref: any) => {
            node.nodes.push({
              nodeid: ref.NodeId,
              label: ref.BrowseName.Name,
              nodes: []
            })
        })
      })
    } catch (e) {
      onMessage(LogMessageType.Error, e)
    }
  }

  async function readAttributes(nodeId: string): Promise<AttributeValueType[] | undefined> {
    try {
      if (server.value == undefined) {
        return
      }

      onMessage(LogMessageType.Info, 'Reading attributes ' + nodeId)
      const resp: any = await server.value.read(nodeId)
      const attributes = resp.Results.filter((r: any, index: number) => {
        if (r.StatusCode == 0 || !("StatusCode" in r)) {
          r.AttributeId = index
          r.Name = OPCUA.getAttributeName(index)
          return true
        }

        return false
      })

      return attributes
    } catch (e) {
      onMessage(LogMessageType.Error, e)
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
