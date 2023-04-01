import { ref, computed } from 'vue'
import { defineStore } from 'pinia'


export const serverState = defineStore('counter', () => {
  const endpointUrl = ref("opc.tcp://localhost:4841")
  const root = ref({
    nodeid: "i=84",
    label: "Root",
    nodes: []
  })
  
  const connected = ref(false)
  const endpoints = ref([])
  const selectedEndpointIndex = ref(0)
  const needAuth = ref(false)

  function connect() {}

  return { endpointUrl, root, endpoints, connected, selectedEndpointIndex, needAuth, connect}
})
