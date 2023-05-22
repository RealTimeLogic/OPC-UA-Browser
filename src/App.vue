<script setup lang="ts">
import AuthModal from './components/AuthModal.vue'
import IconRealtimeLogic from './components/icons/IconRealtimeLogic.vue'
import IconSettings from './components/icons/IconSettings.vue'
import MessageLog from './components/MessageLog.vue'
import UaNodeTree from './components/UaNodeTree.vue'
import UaAttributes from './components/UaAttributes.vue'

import { uaApplication, AttributeValueType } from './stores/UaState'
import { onMounted, provide, ref } from 'vue'

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

provide('selectNode', selectNode)

onMounted(() => {
  const auth = document.getElementById('show-settings-button')
  if (auth) {
    console.log(auth.tagName)
    setTimeout(() => {
      auth.click()
    }, 100)
  }
})

</script>

<template>
  <div class="opcua-client-app" @endpoint.prevent="connectServer" data-bs-theme="light">
    <AuthModal id="auth-dialog" />

    <header>
      <div class="opcua-header" style="height: 100%">
        <button
          id="show-settings-button"
          type="button"
          style="margin: 1em"
          class="btn btn-sm"
          data-bs-toggle="modal"
          data-bs-target="#auth-dialog"
        >
          <IconSettings />
        </button>
        <IconRealtimeLogic class="realtimelogic-header-logo" />
      </div>
    </header>

    <aside>
      <UaNodeTree />
    </aside>
    <main>
      <UaAttributes :attributes="attributes" />
    </main>

    <footer>
      <MessageLog />
    </footer>
  </div>
</template>
