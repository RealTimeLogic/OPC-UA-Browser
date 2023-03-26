<script setup lang="ts">
import IconRealtimeLogic from './components/icons/IconRealtimeLogic.vue'
import IconSettings from './components/icons/IconSettings.vue'
import UaNodeTree from './components/UaNodeTree.vue'

import { uaApplication } from './stores/UaState'
import AuthModal from './components/AuthModal.vue';

function connectServer(evt: CustomEvent) {
  uaApplication().connect(evt.detail)
}

</script>

<template>
  <div class="opcua-client-app" @endpoint.prevent="connectServer" data-bs-theme="light">
    <AuthModal id="auth-dialog"/>

    <header>
      <div class="opcua-header" style="height: 100%;">
        <button type="button" style="margin: 1em;" class="btn btn-sm" data-bs-toggle="modal" data-bs-target="#auth-dialog">
          <IconSettings/>
        </button>
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
