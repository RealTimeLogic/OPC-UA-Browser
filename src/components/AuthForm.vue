<script setup lang="ts">
import { ref } from 'vue'
import { OPCUA, UAServer } from '../utils/ua_server'

import "../../node_modules/bootstrap/dist/css/bootstrap.min.css"
import "../../node_modules/bootstrap/dist/js/bootstrap.min.js"

const endpointUrl = ref('opc.tcp://localhost:4841')
let endpoints: any = ref([])
let selected = ref(false)
let userName = ref("")
let password = ref("")
let certificate = ""

async function fillSecurePolicies(url: string) {
  endpoints.value = []

  const server = new UAServer('ws://localhost/opcua_client.lsp')
  await server.connectWebSocket()
  await server.hello(url)
  await server.openSecureChannel(10000, OPCUA.SecurePolicyUri.None, OPCUA.MessageSecurityMode.None)

  const getEndpointsResp: any = await server.getEndpoints()

  await server.closeSecureChannel()
  await server.disconnectWebSocket()

  for (let endpoint of getEndpointsResp.endpoints) {
    const policyName = OPCUA.getPolicyName(endpoint.securityPolicyUri)
    const modeName = OPCUA.getMessageModeName(endpoint.securityMode)
    endpoint.securityPolicyId = policyName + modeName
    endpoint.encryptionName = policyName
    endpoint.modeName = modeName
  }

  endpoints.value = getEndpointsResp.endpoints
}

var selectedEndpointIdx: number | undefined
var selectedTokenIdx: number | undefined

async function connectEndpoint(evt: Event) {
  if (selectedEndpointIdx == undefined || selectedTokenIdx == undefined) {
    return
  }

  const endpoint = endpoints.value[selectedEndpointIdx]
  const tokenType = endpoint.userIdentityTokens[selectedTokenIdx]

  let secret
  let identity
  switch (tokenType.tokenType) {
    case OPCUA.UserTokenType.UserName:
      identity = userName.value
      secret = password.value
      break;
    case OPCUA.UserTokenType.Certificate:
      identity = certificate
      break;
  }

  const endpointParams = {
    endpointUrl: endpoint.endpointUrl,
    securityPolicyUri: endpoint.securityPolicyUri,
    securityMode: endpoint.securityMode,
    serverCertificate: endpoint.serverCertificate,
    token: {
      policyId: tokenType.policyId,
      identity: identity,
      secret: secret
    }
  }

  const endpointEvent = new CustomEvent("endpoint", {
    bubbles: true,
    detail: endpointParams
  })

  evt.target?.dispatchEvent(endpointEvent)
} 

async function selectToken(eidx: number, tidx: number) {
  selected.value = true
  selectedEndpointIdx = eidx
  selectedTokenIdx = tidx
}

async function loadCert(evt: Event) {
  const file = evt.target.files[0]
  certificate = await file.text();
}

</script>

<template>
  <div id="auth-dialog" class="modal">
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <h2 class="modal-title">Connect to server</h2>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>

        <div class="modal-body">
          <div class="flex-column">
            <div class="flex-row">
              <input v-model="endpointUrl" id="endpointUrl" class="endpoint-url" type="url" placeholder="OPC-UA Endpoint URL"/>
              <button type="button" class="btn btn-secondary" @click.prevent="fillSecurePolicies(endpointUrl)">*</button>
            </div>

            <div class="accordion accordion-flush" id="accordionFlushExample">

              <div class="accordion-item flex-column" v-for="(endpoint, eidx) in endpoints" :key="endpoint.policyName">
                <h2 class="accordion-header">
                  <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" :data-bs-target="'#flush-collapse-' + eidx" aria-expanded="false" :aria-controls="'flush-collapse-'+ eidx">
                    {{ endpoint.encryptionName }} - {{ endpoint.modeName }}
                  </button>
                </h2>

                <div :id="'flush-collapse-'+ eidx" class="accordion-collapse collapse" data-bs-parent="#accordionFlushExample">
                  <div class="accordion-body">
                    <div :id="'tokens-'+eidx" class="flex-column" v-for="(token, tidx) in endpoint.userIdentityTokens" :key="token.policyId">

                      <div class="form-check" v-if="token.tokenType == OPCUA.UserTokenType.Anonymous">
                        <input class="form-check-input" type="radio" :name="'tokentype-e' + eidx" :id="'anonymous-e' + eidx + '-t' + tidx"  @change="selectToken(eidx, tidx)">
                        <label class="form-check-label" :for="'anonymous-e' + eidx + '-t' + tidx">
                          Anonymous
                        </label>
                      </div>

                      <div class="form-check" v-if="token.tokenType == OPCUA.UserTokenType.UserName">
                        <input class="form-check-input" type="radio" :name="'tokentype-e' + eidx" :id="'username-e' + eidx + '-t' + tidx" @change="selectToken(eidx, tidx)">
                        <label class="form-check-label" :for="'username-e' + eidx + '-t' + tidx">Username</label>
                        <div class="input-group mb-3" v-if="token.tokenType == OPCUA.UserTokenType.UserName">
                          <input type="text" class="form-control" placeholder="Username" aria-label="Username" v-model="userName">
                          <span class="input-group-text">@</span>
                          <input type="password" class="form-control" placeholder="Password" aria-label="Server" v-model="password">
                        </div>
                      </div>

                      <div class="form-check" v-if="token.tokenType == OPCUA.UserTokenType.Certificate">
                        <input class="form-check-input" type="radio" :name="'tokentype-e' + eidx" :id="'certificate-e' + eidx + '-t' + tidx"  @change="selectToken(eidx, tidx)">
                        <label class="form-check-label" :for="'certificate-e' + eidx + '-t' + tidx">
                          <div class="mb-3">
                            <label :for="'certificate-e' + eidx + '-t' + tidx" class="form-label">User certificate file</label>
                            <input :name="'certificate-e' + eidx + '-t' + tidx" class="form-control" type="file" id="certificateFile" :onchange="loadCert">
                          </div>
                        </label>
                      </div>
                    
                    </div>

                  </div>
                </div>                

              </div>
            </div>
          </div>
        </div>



        <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
            <button type="button" class="btn btn-primary" data-bs-dismiss="modal" :disabled="!selected" @click="connectEndpoint">Login</button>
        </div>
      </div>
    </div>
  </div>
</template>

<style>

.endpoint-url {
  flex-grow: 1;
}

.connect-button {
}

</style>