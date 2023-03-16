<script setup lang="ts">

import { serverState } from "../stores/opcua"

const server = serverState()

</script>

<template>
  <div>
    <form class="endpoint-config-form">
        <div class="endpoint-select-row">
          <input id="endpointUrl" class="endpoint-url" type="url" v-model="server.endpointUrl" placeholder="OPC-UA Endpoint URL">
        </div>
        <!-- <div class="security-modes">
          <select id="securityMode" class="endpoints-select" v-bind:disabled="server.endpoints.length == 0" v-model="server.selectedEndpointIndex">
            <option v-for="(endpoint, index) in server.endpoints" :key="index" :value="index">{{ endpoint.policyName }} - {{endpoint.securityModeName}}</option>
          </select>
          <input class="fill-endpoints-button" v-on:click="fillSecurePolicies" type="button" value="*">
        </div> -->
        <!-- <input class="connect-button" type="button" value="Connect &#8677;" v-bind:disabled="server.endpoints.length == 0"  v-on:click="server.connect()"> -->
      </form>
  </div>
</template>
