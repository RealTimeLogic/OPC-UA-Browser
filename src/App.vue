<script setup lang="ts">
import AuthModal from './components/AuthModal.vue'
import IconRealtimeLogic from './components/icons/IconRealtimeLogic.vue'
import IconSettings from './components/icons/IconSettings.vue'
import MessageLog from './components/MessageLog.vue'
import UaNodeTree from './components/UaNodeTree.vue'
import UaAttributes from './components/UaAttributes.vue'

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

</script>

<template>
  <div class="opcua-client-app" @endpoint.prevent="connectServer" >
    <AuthModal id="auth-dialog" />

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


<style lang="scss">

.opcua-client-app {
  display: flex;
  flex-direction: column;
   > header {
    background: transparent;
    display: grid;
    grid-template-columns: 300px 1fr;
    align-items: center;
    min-height: 100px;

    .realtimelogic-header-logo {
      height: 80%;
      max-width: 200px;
      padding: 15px;
      img {
        width: 100%;
      }
    }

    .opcua-header {
      width: 100%;
      height: 100%;
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
    top: 101px;
    bottom: 0;
    width: 300px;
    border-right: 1px solid #262323;
  
    overflow: scroll;
  }
  
  main {
    background: #1D1E22;
    position: fixed;
    left: 301px;
    top: 101px;
    bottom: 20%;
    right: 0;
    overflow: auto;
    padding: 4px;
  }
  
  footer {
    position: fixed;
    display: flex;
    left: 301px;
    top: 80%;
    bottom: 0px;
    right: 0;
    padding: 4px;
  }
}

</style>