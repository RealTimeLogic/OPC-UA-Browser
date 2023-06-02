<script setup lang="ts">
import AuthModal from './components/AuthModal.vue'
import IconRealtimeLogic from './components/icons/IconRealtimeLogic.vue'
import IconSettings from './components/icons/IconSettings.vue'
import MessageLog from './components/MessageLog.vue'
import UaNodeTree from './components/UaNodeTree.vue'
import UaAttributes from './components/UaAttributes.vue'
import ServerTime from "./components/ServerTime.vue";

import { uaApplication, AttributeValueType } from './stores/UaState'
import { onMounted, onUnmounted, provide, ref } from 'vue'

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

const serverTime = ref<String>("")

provide('serverTime', selectNode)


onMounted(() => {
  const auth = document.getElementById('show-settings-button')
  if (auth) {
    setTimeout(() => {
      auth.click()
    }, 100)
  }

  const timer = setInterval(async () => {
    const app = uaApplication()
    if (!app.connected) {
      return
    }

    const attrs: any = await app.readAttributes("i=2258")
    const time = attrs.find((val: any) => {
      return val.name == "Value"
    })

    if (time) {
      const date = new Date(time.value.dateTime * 1000)
      serverTime.value = date.toDateString() + " " + date.toLocaleTimeString()
    }

  }, 1000)

  onUnmounted(()=>{
  })

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
        <ServerTime :server-time="serverTime" />
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
