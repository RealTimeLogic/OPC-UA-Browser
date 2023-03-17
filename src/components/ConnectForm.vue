<script setup lang="ts">
import { ref } from 'vue'
import { OPCUA, UAServer } from '../utils/ua_server'

const endpointUrl = ref('opc.tcp://localhost:4841')
const selectedEndpointIndex = ref(0)

let endpoints: any = ref([])

async function fillSecurePolicies(url: string) {
  const server = new UAServer('ws://localhost/opcua_client.lsp')
  await server.connectWebSocket()
  await server.hello(url)
  await server.openSecureChannel(10000, OPCUA.SecurePolicyUri.None, OPCUA.MessageSecurityMode.None)
  const es: any = await server.getEndpoints()
  for (let endpoint of es.endpoints) {
    const policyName = OPCUA.getPolicyName(endpoint.securityPolicyUri)
    const modeName = OPCUA.getMessageModeName(endpoint.securityMode)
    endpoint.policyName = policyName + '-' + modeName
  }
  endpoints.value = es.endpoints
}

async function connectEndpoint(idx: number) {
  alert(endpoints.value[idx].policyName)
}
</script>

<template>
  <div>
    <form class="endpoint-config-form">
      <div class="endpoint-select-row">
        <input
          v-model="endpointUrl"
          id="endpointUrl"
          class="endpoint-url"
          type="url"
          placeholder="OPC-UA Endpoint URL"
        />
        <input
          class="fill-endpoints-button"
          v-on:click="fillSecurePolicies(endpointUrl)"
          type="button"
          value="*"
        />
      </div>
      <div class="security-modes">
        <select
          id="securityMode"
          class="endpoints-select"
          v-bind:disabled="endpoints.length == 0"
          v-model="selectedEndpointIndex"
        >
          <option v-for="(endpoint, index) in endpoints" :key="index" :value="index">
            {{ endpoint.policyName }}
          </option>
        </select>
      </div>
      <input
        class="connect-button"
        type="button"
        value="Connect &#8677;"
        v-bind:disabled="endpoints.length == 0"
        v-on:click="connectEndpoint(selectedEndpointIndex)"
      />
    </form>
  </div>
</template>
