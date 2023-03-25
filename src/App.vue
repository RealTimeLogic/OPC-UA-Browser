<script setup lang="ts">
import IconRealtimeLogic from './components/icons/IconRealtimeLogic.vue'
import ConnectForm from './components/ConnectForm.vue';
import UaNodeTree from './components/UaNodeTree.vue'

import { uaApplication } from './stores/UaState'
import AuthForm from './components/AuthForm.vue';

function connectServer(evt: CustomEvent) {
  uaApplication().connect(evt.detail)
}

</script>

<template>
  <div class="opcua-client-app" @endpoint.prevent="connectServer" data-bs-theme="light">
    <AuthForm/>

    <header>
      <div class="opcua-header">
        <ConnectForm/>
        <IconRealtimeLogic class="realtimelogic-header-logo" />
      </div>
    </header>

    <aside>
      <UaNodeTree/>
    </aside>
<!--
    <main>
      <ua-attributes/>
    </main>

    <footer>
      <ua-messages/>
    </footer>

    <ua-login v-if="needAuth"/> -->

    <!-- <RouterView /> -->
  </div>
</template>
