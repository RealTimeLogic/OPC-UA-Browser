import { defineStore } from 'pinia'
import { UAServer } from '../utils/ua_server'

type NodeType = {
    nodeid: string,
    label: string,
    nodes: NodeType[]
}

type UaStateType = {
    server: UAServer | undefined,
    webSockURL: string,
    root: NodeType,
    needAuth: boolean
}

export const uaApplication = defineStore({
    id: "uaApplication",
    state: () :UaStateType => {
        return {
            webSockURL: 'ws://localhost/opcua_client.lsp',
            server: undefined,
            needAuth: false,
            root: {
                nodeid: "i=84",
                label: "RootFolder",
                nodes: []
            }
        }
    },

    getters: {
        connected() :boolean {
            return this.server != undefined
        }
    },

    actions: {
        async connect(endpoint: any) {
            const server = new UAServer(this.webSockURL)
            await server.connectWebSocket()
            await server.hello(endpoint.endpointUrl)
            await server.openSecureChannel(360000, endpoint.securityPolicyUri, endpoint.securityMode, endpoint.serverCertificate)
            await server.createSession("opcua web session", 3600000)
            await server.activateSession(endpoint.token.policyId, endpoint.token.identity, endpoint.token.secret)
            this.server = server
        },

        async browse(node: NodeType) {
            try {
                if (node.nodes.length != 0) {
                    node.nodes = []
                    return
                }

                // onMessage("msg", "Browsing nodeID " + this.root.nodeid)
                const resp: any = await this.server.browse(node.nodeid)
                resp.results.forEach((result: any) => {
                    result.references.forEach((ref: any) => {
                        node.nodes.push({
                            nodeid: ref.nodeId,
                            label: ref.browseName.name,
                            nodes: []
                        })
                    })
                });

            } catch (e) {
                // onMessage("err", e)
            }
        }
    },
})
