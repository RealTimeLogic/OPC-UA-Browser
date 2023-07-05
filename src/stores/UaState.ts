import { defineStore } from 'pinia'
import { computed, ref } from 'vue'
import { UAServer, OPCUA } from '../utils/ua_server'

export type AttributeValueType = {
  name: string
  attributeId: number
  value: any
}

export type NodeType = {
  nodeid: string
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
  server: UAServer | undefined
  webSockURL: string
  root: NodeType
  needAuth: boolean
  messages: LogEntryType[]
}

function opcuaWebSockURL() {
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
  const server = ref<UAServer | undefined>(undefined)

  const webSockURL = ref(opcuaWebSockURL())
  const needAuth = ref(false)
  const root = ref<NodeType>({
    nodeid: 'i=84',
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
      onMessage(LogMessageType.Info, 'Connecting to websocket ' + webSockURL.value)
      const srv = new UAServer(webSockURL.value)
      await srv.connectWebSocket()

      onMessage(LogMessageType.Info, 'Connecting to endpoint ' + endpoint.endpointUrl)
      await srv.hello(endpoint.endpointUrl)

      onMessage(LogMessageType.Info, 'Opening secure channel')
      await srv.openSecureChannel(
        360000,
        endpoint.securityPolicyUri,
        endpoint.securityMode,
        endpoint.serverCertificate
      )

      onMessage(LogMessageType.Info, 'Creating session')
      await srv.createSession('opcua web session', 3600000)

      onMessage(LogMessageType.Info, 'Logging to OPCUA server')
      await srv.activateSession(
        endpoint.token.policyId,
        endpoint.token.identity,
        endpoint.token.secret
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
      const resp: any = await server.value.browse(node.nodeid)
      resp.results.forEach((result: any) => {
        result.references.forEach((ref: any) => {
          node.nodes.push({
            nodeid: ref.nodeId,
            label: ref.browseName.name,
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
      const attributes = resp.results.filter((r: any, index: number) => {
        if (r.statusCode == 0) {
          r.attributeId = index
          r.name = OPCUA.getAttributeName(index)
        }

        return r.statusCode == 0
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
