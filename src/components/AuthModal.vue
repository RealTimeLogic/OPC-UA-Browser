<script setup lang="ts">
import { ref, onMounted, Ref, computed } from 'vue'
import * as OPCUA from 'opcua-client'
import { createServer }  from "../utils/ua_server"
import { Modal } from 'bootstrap';

import { uaApplication, LogMessageType} from '../stores/UaState'

export interface AuthProps {
  id: string
}

const props = withDefaults(defineProps<AuthProps>(), {
  id: 'auth-dialog'
})


const hostname = window.location.hostname || 'localhost';
let endpointUrl = ref(`opc.tcp://${hostname}:4841`)
let endpoints: any = ref([])
let userName: Ref<string> = ref('')
let password: Ref<string> = ref('')

var selectedEndpointIdx: Ref<number | undefined> = ref(undefined)
var selectedTokenIdx: Ref<number | undefined> = ref(undefined)
let certificateFile: Ref<File | undefined> = ref(undefined)

const modal: Ref<HTMLDivElement> | Ref<null> = ref(null)
const connectButton: Ref<HTMLButtonElement> | Ref<null> = ref(null)

async function fillSecurePolicies(url: string, newRequest: boolean = false) {
  if (newRequest) {
    clearLocalStorages();
  }
  window.localStorage.setItem('localEndpointUrl', url);
  try {
    endpoints.value = []
    let server = createServer(url, uaApplication().opcuaWebSockURL())
    await server.connect()
    await server.hello(url)
    await server.openSecureChannel(10000, OPCUA.SecurePolicyUri.None, OPCUA.MessageSecurityMode.None)

    const getEndpointsResp: any = await server.getEndpoints()

    try {
      await server.closeSecureChannel()
    } catch (err) {
      // ignore
    }

    await server.disconnect()

    for (let endpoint of getEndpointsResp.Endpoints) {
      const policyName = OPCUA.getPolicyName(endpoint.SecurityPolicyUri)
      const modeName = OPCUA.getMessageModeName(endpoint.SecurityMode)
      endpoint.SecurityPolicyId = policyName + modeName
      endpoint.EncryptionName = policyName
      endpoint.ModeName = modeName
      endpoint.Transport = OPCUA.getTransportName(endpoint.TransportProfileUri)
    }

    endpoints.value = getEndpointsResp.Endpoints
  } catch (err) {
    uaApplication().onMessage(LogMessageType.Error, err)
  }
}

async function connectEndpoint(): Promise<boolean> {
  if (selectedEndpointIdx.value == undefined || selectedTokenIdx.value == undefined) {
    return false
  }

  const endpoint = endpoints.value[selectedEndpointIdx.value]
  const tokenType = endpoint.UserIdentityTokens[selectedTokenIdx.value]

  let secret
  let identity
  switch (tokenType.TokenType) {
    case OPCUA.UserTokenType.UserName:
      identity = userName.value
      secret = password.value
      break
    case OPCUA.UserTokenType.Certificate: {
      identity = await certificateFile.value?.text()
      break
    }
  }

  const endpointParams = {
    EndpointUrl: endpoint.EndpointUrl,
    TransportProfileUri: endpoint.TransportProfileUri,
    SecurityPolicyUri: endpoint.SecurityPolicyUri,
    SecurityMode: endpoint.SecurityMode,
    ServerCertificate: endpoint.ServerCertificate,
    Token: {
      TokenType: tokenType,
      Identity: identity,
      Secret: secret
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
  // Close modal
  const modalBS = Modal.getInstance(modal.value!)
  modalBS?.hide()
  return true
}

async function selectToken(eidx: number, tidx: number) {
  selectedEndpointIdx.value = eidx
  selectedTokenIdx.value = tidx
  window.localStorage.setItem('localeidx', eidx.toString());
  window.localStorage.setItem('localetidx', tidx.toString());
}

const selected = computed(() => {
  const idx = selectedEndpointIdx.value;
  const tidx = selectedTokenIdx.value;
  if (idx === undefined)
    return false;

  if (tidx === undefined)
    return false;

  if (!endpoints.value[idx])
    return false;

  if (!endpoints.value[idx]?.UserIdentityTokens[tidx])
    return false;

  const endpoint = endpoints.value[idx].UserIdentityTokens[tidx]
  if (endpoint.TokenType === OPCUA.UserTokenType.Anonymous)
    return true;

  if (endpoint.TokenType === OPCUA.UserTokenType.UserName && userName.value !== '' && userName.value !== '')
    return true;

  if (endpoint.TokenType === OPCUA.UserTokenType.Certificate && certificateFile.value !== undefined)
    return true;

  return false
});


async function onSelectedCert(evt: Event) {
  const file = (evt.target as HTMLInputElement).files?.item(0)
  if (file) {
    certificateFile.value = file
  }
}

onMounted( async () => {

  /** Automaticaly try get endpoints and login to last */
  const localUser = window.localStorage.getItem('localUser') || false
  const localPass = window.localStorage.getItem('localPass') || false
  const localEndpointUrl = window.localStorage.getItem('localEndpointUrl') || false
  const localeidx = window.localStorage.getItem('localeidx') || false
  const localetidx = window.localStorage.getItem('localetidx') || false

  if (localUser && localPass && localEndpointUrl && localeidx && localetidx) {
    await fillSecurePolicies(endpointUrl.value);

    // Try check if idx and tidx exists in endpoits url
    if (endpoints.value[localeidx]?.UserIdentityTokens[localetidx]) {
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
  window.localStorage.removeItem('localEndpointUrl')
  window.localStorage.removeItem('localeidx')
  window.localStorage.removeItem('localetidx')
}


function truncate(str: string) {
  const n = 40
  return str.length > n ? str.substr(0, n - 10) + ' ... ' + str.substr(str.length - 10) : str
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
                :placeholder="`opc.tcp://${hostname}:4841`"
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

            <div class="accordion accordion-flush" id="accordionFlush">
              <div
                class="accordion-item flex-column endpoint-params"
                v-for="(endpoint, eidx) in endpoints"
                :key="endpoint.policyName"
              >
                <h2 class="accordion-header">
                  <button
                    class="accordion-button fill-endpoints-button text-wrap"
                    type="button"
                    data-bs-toggle="collapse"
                    :class="{collapsed : selectedEndpointIdx !== eidx}"
                    :data-bs-target="'#flush-collapse-' + eidx"
                    :aria-expanded="selectedEndpointIdx === eidx ? 'true' : 'false'"
                    :aria-controls="'flush-collapse-' + eidx"
                  >
                    <div>
                      <h5>{{ endpoint.Transport }} - {{ endpoint.ModeName }} - {{ endpoint.EncryptionName }}</h5>
                      <h6 :title="endpoint.EndpointUrl">{{ truncate(endpoint.EndpointUrl) }}</h6>
                    </div>
                  </button>
                </h2>

                <div
                  :id="'flush-collapse-' + eidx"
                  class="accordion-collapse collapse"
                  :class="{show: selectedEndpointIdx === eidx}"
                  data-bs-parent="#accordionFlush"
                >
                  <div class="accordion-body">
                    <div
                      :id="'tokens-' + eidx"
                      class="flex-column"
                      v-for="(token, tidx) in endpoint.UserIdentityTokens"
                      :key="token.PolicyId"
                    >
                      <div
                        class="form-check"
                        v-if="token.TokenType == OPCUA.UserTokenType.Anonymous"
                      >
                        <input
                          class="form-check-input"
                          type="radio"
                          :name="'tokentype-e' + eidx"
                          :id="'e' + eidx + '-t' + tidx"
                          :checked="eidx == selectedEndpointIdx && tidx == selectedTokenIdx"
                          @change="selectToken(eidx, tidx)"
                        />
                        <label class="form-check-label" :for="'e' + eidx + '-t' + tidx">
                          Anonymous
                        </label>
                      </div>

                      <div
                        class="form-check"
                        v-if="token.TokenType == OPCUA.UserTokenType.UserName"
                      >
                        <input
                          class="form-check-input"
                          type="radio"
                          :name="'tokentype-e' + eidx"
                          :id="'e' + eidx + '-t' + tidx"
                          :checked="eidx == selectedEndpointIdx && tidx == selectedTokenIdx"
                          @change="selectToken(eidx, tidx)"
                        />
                        <label class="form-check-label" :for="'e' + eidx + '-t' + tidx"
                          >Username</label
                        >
                        <div
                          class="input-group mb-3"
                          v-if="token.TokenType == OPCUA.UserTokenType.UserName"
                        >
                          <input
                            type="text"
                            class="form-control"
                            placeholder="Username"
                            aria-label="Username"
                            v-model="userName"
                            @keyup.enter="connectEndpoint"
                          />
                          <span class="input-group-text">@</span>
                          <input
                            type="password"
                            class="form-control"
                            placeholder="Password"
                            aria-label="Server"
                            v-model="password"
                            @keyup.enter="connectEndpoint"
                          />
                        </div>
                      </div>

                      <div
                        class="form-check"
                        v-if="token.TokenType == OPCUA.UserTokenType.Certificate"
                      >
                        <input
                          class="form-check-input"
                          type="radio"
                          :name="'tokentype-e' + eidx"
                          :id="'e' + eidx + '-t' + tidx"
                          :checked="eidx == selectedEndpointIdx && tidx == selectedTokenIdx"
                          @change="selectToken(eidx, tidx)"
                        />
                        <label class="form-check-label" :for="'e' + eidx + '-t' + tidx">
                          <div class="mb-3">
                            <label :for="'e' + eidx + '-t' + tidx" class="form-label"
                              >User certificate file</label
                            >
                            <input
                              :name="'e' + eidx + '-t' + tidx"
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

<style lang="scss">
.modal {

  --bs-modal-bg: #24262B;
  --bs-modal-border-color: var(--bs-border-color-translucent);
  --bs-modal-box-shadow: 0 0.125rem 0.25rem rgba(255, 255, 255, 0.15);

  .btn-close {
    filter: invert(1);
  }

  .endpoint-url {
    flex-grow: 1;
  }
.form-control {
    background-color: #060606;
    border-color: #262323;
    color: #FFFFFF;
    &:focus {
      background-color: #060606;
      border-color: #d4e5ff;
      color: #FFFFFF;
    }
  }
  .accordion  {
    --bs-accordion-color: #FFFFFF;
    --bs-accordion-bg: #212529;
    --bs-accordion-btn-color: #FFFFFF;

    --bs-accordion-btn-focus-border-color: #d4e5ff;
    --bs-accordion-btn-focus-box-shadow: 0 0 0 0.25rem rgba(13, 110, 253, 0.25);
    --bs-accordion-active-bg: #060606;
    --bs-accordion-active-color: #FFFFFF;
    --bs-accordion-btn-icon: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16' fill='%23FFFFFF'%3e%3cpath fill-rule='evenodd' d='M1.646 4.646a.5.5 0 0 1 .708 0L8 10.293l5.646-5.647a.5.5 0 0 1 .708.708l-6 6a.5.5 0 0 1-.708 0l-6-6a.5.5 0 0 1 0-.708z'/%3e%3c/svg%3e");
    .accordion-item {
      border-bottom: 3px solid #060606;
    }
  }
}
</style>
