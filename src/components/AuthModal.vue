<script setup lang="ts">
import { ref, onMounted, Ref, computed } from 'vue'
import * as OPCUA from 'opcua-client'
import { createUaClient }  from "../utils/ua_client_proxy"
import { Modal } from 'bootstrap';

import { uaApplication, LogMessageType, ConnectionParams} from '../stores/UaState'

export interface AuthProps {
  id?: string
}

const props = withDefaults(defineProps<AuthProps>(), {
  id: 'auth-dialog'
})


export type EndpointSelection = OPCUA.EndpointDescription & {
  PolicyName: string
  ModeName: string
  Transport: string
}


const hostname = window.location.hostname || 'localhost';
const endpointUrl = ref(`opc.tcp://${hostname}:4841`)
const endpoints: Ref<EndpointSelection[]> = ref([])
const userName: Ref<string> = ref('')
const password: Ref<string> = ref('')

const selectedEndpointIdx: Ref<number | undefined> = ref(undefined)
const selectedTokenIdx: Ref<number | undefined> = ref(undefined)
const certificateFile: Ref<File | undefined> = ref(undefined)

const modal: Ref<HTMLDivElement> | Ref<null> = ref(null)
const connectButton: Ref<HTMLButtonElement> | Ref<null> = ref(null)

async function fillSecurePolicies(endpointUrl: string, newRequest: boolean = false) {
  if (newRequest) {
    clearLocalStorages();
  }
  window.localStorage.setItem('localEndpointUrl', endpointUrl);
  try {
    endpoints.value = []
    const server = createUaClient(endpointUrl, uaApplication().opcuaWebSockURL())

    await server.hello(endpointUrl)
    await server.openSecureChannel(10000, OPCUA.SecurePolicyUri.None, OPCUA.MessageSecurityMode.None)

    const getEndpointsResp: OPCUA.GetEndpointsData = await server.getEndpoints()

    try {
      await server.closeSecureChannel()
    } catch (err: unknown) {
      uaApplication().onMessage(LogMessageType.Error, err instanceof Error ? err.message : String(err))
    }

    for (const endpoint of getEndpointsResp.Endpoints) {

      const policyName = OPCUA.getPolicyName(endpoint.SecurityPolicyUri)
      const modeName = OPCUA.getMessageModeName(endpoint.SecurityMode)

      const endpointExtended: EndpointSelection = {
        ...endpoint,
        PolicyName: policyName,
        ModeName: modeName,
        Transport: OPCUA.getTransportName(endpoint.TransportProfileUri as OPCUA.TransportProfile)
      }

      endpoints.value.push(endpointExtended)
    }
  } catch (err: unknown) {
    uaApplication().onMessage(LogMessageType.Error, err instanceof Error ? err.message : String(err))
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

  const endpointParams: ConnectionParams = {
    EndpointUrl: endpoint.EndpointUrl,
    TransportProfileUri: endpoint.TransportProfileUri,
    SecurityPolicyUri: endpoint.SecurityPolicyUri,
    SecurityMode: endpoint.SecurityMode,
    ServerCertificate: endpoint.ServerCertificate,
    Token: {
      TokenPolicy: tokenType,
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
  const localeidx = parseInt(window.localStorage.getItem('localeidx') || '0')
  const localetidx = parseInt(window.localStorage.getItem('localetidx') || '0')

  if (localUser && localPass && localEndpointUrl && localeidx && localetidx) {
    await fillSecurePolicies(endpointUrl.value);

    // Try check if idx and tidx exists in endpoits url
    if (endpoints.value[localeidx]?.UserIdentityTokens[localetidx]) {
      selectToken(localeidx, localetidx);
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

            <div id="accordionFlush" class="accordion accordion-flush">
              <div
                v-for="(endpoint, eidx) in endpoints"
                :key="endpoint.PolicyName"
                class="accordion-item flex-column endpoint-params"
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
                      <h5>{{ endpoint.Transport }} - {{ endpoint.ModeName }} - {{ endpoint.PolicyName }}</h5>
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
                      v-for="(token, tidx) in endpoint.UserIdentityTokens"
                      :id="'tokens-' + eidx"
                      :key="token.PolicyId"
                      class="flex-column"
                    >
                      <div
                        v-if="token.TokenType == OPCUA.UserTokenType.Anonymous"
                        class="form-check"
                      >
                        <input
                          :id="'e' + eidx + '-t' + tidx"
                          class="form-check-input"
                          type="radio"
                          :name="'tokentype-e' + eidx"
                          :checked="eidx == selectedEndpointIdx && tidx == selectedTokenIdx"
                          @change="selectToken(eidx, tidx)"
                        />
                        <label class="form-check-label" :for="'e' + eidx + '-t' + tidx">
                          Anonymous
                        </label>
                      </div>

                      <div
                        v-if="token.TokenType == OPCUA.UserTokenType.UserName"
                        class="form-check"
                      >
                        <input
                          :id="'e' + eidx + '-t' + tidx"
                          class="form-check-input"
                          type="radio"
                          :name="'tokentype-e' + eidx"
                          :checked="eidx == selectedEndpointIdx && tidx == selectedTokenIdx"
                          @change="selectToken(eidx, tidx)"
                        />
                        <label class="form-check-label" :for="'e' + eidx + '-t' + tidx"
                          >Username</label
                        >
                        <div
                          v-if="token.TokenType == OPCUA.UserTokenType.UserName"
                          class="input-group mb-3"
                        >
                          <input
                            v-model="userName"
                            type="text"
                            class="form-control"
                            placeholder="Username"
                            aria-label="Username"
                            @keyup.enter="connectEndpoint"
                          />
                          <span class="input-group-text">@</span>
                          <input
                            v-model="password"
                            type="password"
                            class="form-control"
                            placeholder="Password"
                            aria-label="Server"
                            @keyup.enter="connectEndpoint"
                          />
                        </div>
                      </div>

                      <div
                        v-if="token.TokenType == OPCUA.UserTokenType.Certificate"
                        class="form-check"
                      >
                        <input
                          :id="'e' + eidx + '-t' + tidx"
                          class="form-check-input"
                          type="radio"
                          :name="'tokentype-e' + eidx"
                          :checked="eidx == selectedEndpointIdx && tidx == selectedTokenIdx"
                          @change="selectToken(eidx, tidx)"
                        />
                        <label class="form-check-label" :for="'e' + eidx + '-t' + tidx">
                          <div class="mb-3">
                            <label :for="'e' + eidx + '-t' + tidx" class="form-label"
                              >User certificate file</label
                            >
                            <input
                              id="certificateFile"
                              :name="'e' + eidx + '-t' + tidx"
                              class="form-control"
                              type="file"
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
            ref="connectButton"
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
