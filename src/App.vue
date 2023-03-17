<script setup lang="ts">
import IconRealtimeLogic from './components/icons/IconRealtimeLogic.vue'
import ConnectForm from './components/ConnectForm.vue'
</script>

<template>
  <div class="opcua-client-app">
    <header>
      <div class="opcua-header">
        <ConnectForm />
        <IconRealtimeLogic class="realtimelogic-header-logo" />
      </div>
    </header>

    <!-- 
    <aside>
      <div class="node-tree"> 
        <ua-node :root="root" :connected="connected" v-if="connected"/>
      </div>
    </aside>

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
