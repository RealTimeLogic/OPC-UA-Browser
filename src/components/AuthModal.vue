<script setup lang="ts">
import { ref } from 'vue'
import { OPCUA, UAServer } from '../utils/ua_server'

import '../../node_modules/bootstrap/dist/css/bootstrap.min.css'
import 'bootstrap/dist/js/bootstrap.min'
import { uaApplication, LogMessageType} from '../stores/UaState'

export interface AuthProps {
  id: string
}

const props = withDefaults(defineProps<AuthProps>(), {
  id: 'auth-dialog'
})

const endpointUrl = ref('opc.tcp://localhost:4841')
let endpoints: any = ref([])
let selected = ref(false)
let userName = ref('')
let password = ref('')
let certificateFile: File | undefined

async function fillSecurePolicies(url: string) {
  try {
    endpoints.value = []

    const server = new UAServer(uaApplication().opcuaWebSockURL())
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
  } catch (err) {
    uaApplication().onMessage(LogMessageType.Error, err)
  }
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
      break
    case OPCUA.UserTokenType.Certificate: {
      identity = await certificateFile?.text()
      break
    }
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

  const endpointEvent = new CustomEvent('endpoint', {
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

async function onSelectedCert(evt: Event) {
  const file = (evt.target as HTMLInputElement).files?.item(0)
  if (file) {
    certificateFile = file
  }
}
</script>

<template>
  <div :id="props.id" class="modal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable">
      <div class="modal-content">
        <div class="modal-header">
          <h2 class="modal-title">Connection parameters</h2>
          <button
            type="button"
            class="btn-close"
            data-bs-dismiss="modal"
            aria-label="Close"
          ></button>
        </div>

        <div class="modal-body">
          <div class="flex-column">
            <div class="input-group">
              <input
                v-model="endpointUrl"
                type="text"
                class="form-control endpoint-url"
                placeholder="opc.tcp://localhost:4841"
                aria-label="Endpoint URL"
                aria-describedby="basic-addon1"
              />
              <button
                type="button"
                class="btn btn-secondary btn-sm fill-endpoints-button"
                @click.prevent="fillSecurePolicies(endpointUrl)"
              >
                Get endpoints
              </button>
            </div>

            <div class="accordion accordion-flush" id="accordionFlushExample">
              <div
                class="accordion-item flex-column endpoint-params"
                v-for="(endpoint, eidx) in endpoints"
                :key="endpoint.policyName"
              >
                <h2 class="accordion-header">
                  <button
                    class="accordion-button collapsed fill-endpoints-button"
                    type="button"
                    data-bs-toggle="collapse"
                    :data-bs-target="'#flush-collapse-' + eidx"
                    aria-expanded="false"
                    :aria-controls="'flush-collapse-' + eidx"
                  >
                    {{ endpoint.encryptionName }} - {{ endpoint.modeName }}
                  </button>
                </h2>

                <div
                  :id="'flush-collapse-' + eidx"
                  class="accordion-collapse collapse"
                  data-bs-parent="#accordionFlushExample"
                >
                  <div class="accordion-body">
                    <div
                      :id="'tokens-' + eidx"
                      class="flex-column"
                      v-for="(token, tidx) in endpoint.userIdentityTokens"
                      :key="token.policyId"
                    >
                      <div
                        class="form-check"
                        v-if="token.tokenType == OPCUA.UserTokenType.Anonymous"
                      >
                        <input
                          class="form-check-input"
                          type="radio"
                          :name="'tokentype-e' + eidx"
                          :id="'anonymous-e' + eidx + '-t' + tidx"
                          @change="selectToken(eidx, tidx)"
                        />
                        <label class="form-check-label" :for="'anonymous-e' + eidx + '-t' + tidx">
                          Anonymous
                        </label>
                      </div>

                      <div
                        class="form-check"
                        v-if="token.tokenType == OPCUA.UserTokenType.UserName"
                      >
                        <input
                          class="form-check-input"
                          type="radio"
                          :name="'tokentype-e' + eidx"
                          :id="'username-e' + eidx + '-t' + tidx"
                          @change="selectToken(eidx, tidx)"
                        />
                        <label class="form-check-label" :for="'username-e' + eidx + '-t' + tidx"
                          >Username</label
                        >
                        <div
                          class="input-group mb-3"
                          v-if="token.tokenType == OPCUA.UserTokenType.UserName"
                        >
                          <input
                            type="text"
                            class="form-control"
                            placeholder="Username"
                            aria-label="Username"
                            v-model="userName"
                          />
                          <span class="input-group-text">@</span>
                          <input
                            type="password"
                            class="form-control"
                            placeholder="Password"
                            aria-label="Server"
                            v-model="password"
                          />
                        </div>
                      </div>

                      <div
                        class="form-check"
                        v-if="token.tokenType == OPCUA.UserTokenType.Certificate"
                      >
                        <input
                          class="form-check-input"
                          type="radio"
                          :name="'tokentype-e' + eidx"
                          :id="'certificate-e' + eidx + '-t' + tidx"
                          @change="selectToken(eidx, tidx)"
                        />
                        <label class="form-check-label" :for="'certificate-e' + eidx + '-t' + tidx">
                          <div class="mb-3">
                            <label :for="'certificate-e' + eidx + '-t' + tidx" class="form-label"
                              >User certificate file</label
                            >
                            <input
                              :name="'certificate-e' + eidx + '-t' + tidx"
                              class="form-control"
                              type="file"
                              id="certificateFile"
                              :onchange="onSelectedCert"
                            />
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
          <button
            type="button"
            class="btn btn-primary login-button"
            data-bs-dismiss="modal"
            :disabled="!selected"
            @click="connectEndpoint"
          >
            Login
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style>
.endpoint-url {
  flex-grow: 1;
}
</style>
