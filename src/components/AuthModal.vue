<script setup lang="ts">
import { ref, onMounted, Ref } from 'vue'
import { OPCUA, UAServer } from '../utils/ua_server'
import { Modal } from 'bootstrap';

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

const modal: Ref<HTMLDivElement> | Ref<null> = ref(null)
const connectButton: Ref<HTMLButtonElement> | Ref<null> = ref(null)

async function fillSecurePolicies(url: string, newRequest: boolean = false) {
  if (newRequest) {
    clearLocalStorages();
  }
  window.localStorage.setItem('localURL', url);
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

async function connectEndpoint(evt?: Event): Promise<boolean> {
  if (selectedEndpointIdx == undefined || selectedTokenIdx == undefined) {
    return false
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
  
  // Save to local storage
  if (identity !== undefined && secret !== undefined) {
    window.localStorage.setItem('localUser', identity);
    window.localStorage.setItem('localPass', secret);
  }

  const endpointEvent = new CustomEvent('endpoint', {
    bubbles: true,
    detail: endpointParams
  })

  connectButton.value?.dispatchEvent(endpointEvent)
  if (! evt){
    // Close modal
    const modalBS = Modal.getInstance(modal.value!)
    modalBS?.hide()
    return true
  }
  return false
}

async function selectToken(eidx: number, tidx: number) {
  selected.value = true
  selectedEndpointIdx = eidx
  selectedTokenIdx = tidx
  window.localStorage.setItem('localeidx', eidx.toString());
  window.localStorage.setItem('localetidx', tidx.toString());
}

async function onSelectedCert(evt: Event) {
  const file = (evt.target as HTMLInputElement).files?.item(0)
  if (file) {
    certificateFile = file
  }
}

onMounted( async () => {

  /** Automaticaly try get endpoints and login to last */
  const localUser = window.localStorage.getItem('localUser') || false
  const localPass = window.localStorage.getItem('localPass') || false
  const localURL = window.localStorage.getItem('localURL') || false
  const localeidx = window.localStorage.getItem('localeidx') || false
  const localetidx = window.localStorage.getItem('localetidx') || false
  
  
  if (localUser && localPass && localURL && localeidx && localetidx) {
    await fillSecurePolicies(endpointUrl.value);
    
    // Try check if idx and tidx exists in endpoits url
    if (endpoints.value[localeidx]?.userIdentityTokens[localetidx]) {
      selectToken(parseInt(localeidx), parseInt(localetidx));
      userName.value = localUser;
      password.value = localPass;
      const response = await connectEndpoint();
      if (response) {
        return true;
      }
    }
  }
  else {
    // Clear local database
    clearLocalStorages();
  }
  openModal();
})

// Open modal
function openModal() {
  const modalBS = Modal.getOrCreateInstance(modal.value!)
  modalBS?.show()
}

// Clear all local storage
function clearLocalStorages() {
  window.localStorage.removeItem('localUser')
  window.localStorage.removeItem('localPass')
  window.localStorage.removeItem('localURL')
  window.localStorage.removeItem('localeidx')
  window.localStorage.removeItem('localetidx')
}


</script>

<template>
  <div :id="props.id" ref="modal" class="modal" tabindex="-1">
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
                @click.prevent="fillSecurePolicies(endpointUrl, true)"
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
            ref="connectButton"
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
