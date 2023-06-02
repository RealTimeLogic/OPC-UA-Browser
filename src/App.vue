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

  // Read time on server preiodically to keep OPCUA session alive
  const readPeriodMs: number = 60000
  const timer = setInterval(async () => {
    const app = uaApplication()
    if (!app.connected) {
      return
    }

    const attrs: any = await app.readAttributes("i=2258")
    // const time = attrs.find((val: any) => {
    //   return val.name == "Value"
    // })

    // if (time) {
    //   const date = new Date(time.value.dateTime * 1000)
    //   serverTime.value = date.toDateString() + " " + date.toLocaleTimeString()
    // }

  }, readPeriodMs)

  onUnmounted(()=>{
  })

})

</script>

<template>
  <div class="opcua-client-app" @endpoint.prevent="connectServer" >
    <AuthModal id="auth-dialog" />


    <aside>
      <header>
        <IconRealtimeLogic class="realtimelogic-header-logo" />
        <div class="opcua-header">
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
        </div>
      </header>
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


<style lang="scss">

.opcua-client-app {
  display: flex;
  flex-direction: column;
   header {
    background: #000000;
    display: grid;
    grid-template-columns: auto auto;
    align-items: center;
    height: 150px;


  .opcua-header {
    width: 100%;
    height: 150px;
    display: flex;
    justify-content: flex-end;
    align-items: center;
  }
  }
  aside {
    position: fixed;
    display: flex;
    flex-direction: column;
    background: #1D1E22;
    left: 0;
    bottom: 0;
    width: 300px;
    top: 0;
    border-right: 1px solid #262323;
    min-height: 100vh;
    overflow: scroll;

    .realtimelogic-header-logo {
      margin: 0 0 0 15px;
      img {
        width: 170px;
      }
    }
  }

  main {
    background: #1D1E22;
    position: fixed;
    left: 301px;
    top: 150px;
    bottom: 0;
    right: 0;
    overflow: auto;
    padding: 4px;
  }

  footer {
    position: fixed;
    display: flex;
    left: 301px;
    top: 0;
    right: 0;
    height: 150px;
    padding: 4px;
  }
}

</style>