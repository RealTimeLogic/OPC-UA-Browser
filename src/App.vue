<script setup lang="ts">
import IconRealtimeLogic from './components/icons/IconRealtimeLogic.vue'
import IconSettings from './components/icons/IconSettings.vue'
import UaNodeTree from './components/UaNodeTree.vue'
import UaAttributes from './components/UaAttributes.vue'

import { uaApplication, AttributeValueType } from './stores/UaState'
import AuthModal from './components/AuthModal.vue';
import { provide, ref } from 'vue'
import MessageLog from './components/MessageLog.vue'

function connectServer(evt: CustomEvent) {
  uaApplication().connect(evt.detail)
}

const attributes = ref<AttributeValueType[]>([])

async function selectNode(nodeId: string) {
  const attrs = await uaApplication().readAttributes(nodeId)
  if (attrs) {
    attributes.value = attrs
  }
}

provide("attributes", attributes)
provide("selectNode", selectNode)

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
    <main>
      <UaAttributes/>
    </main>

    <footer>
      <MessageLog :messages="uaApplication().messages"/>
    </footer>
  </div>
</template>
