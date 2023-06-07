<template>
  <img v-if="uaStore.connected" width="32" height="32" src="@/assets/icons8-connect-50.png" />
  <img v-else width="32" height="32" src="@/assets/icons8-disconnected-60.png" />
</template>


<script setup  lang="ts">
import { uaApplication } from '../../stores/UaState';

const uaStore = uaApplication();
</script>
