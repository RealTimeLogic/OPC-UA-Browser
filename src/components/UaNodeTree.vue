<script setup lang="ts">
import UaNode from './UaNode.vue'
import { uaApplication } from '../stores/UaState'
</script>

<template>
  <div class="flex-column">
    <div v-if="uaApplication().connected">
      <UaNode class="node-children" :root="uaApplication().root" />
    </div>
  </div>
</template>

<style>
.node-tree {
  padding: 5px;
  width: 100%;
}

.node-row {
  display: flex;
  cursor: pointer;
  align-items: center;
  justify-content: left;
}

.node-plus {
  display: inline-block;
  width: 14px;
  height: 20px;
  text-align: left;
  vertical-align: middle;
  padding: auto;
}

.node-name {
  display: inline-block;
}

.node-name:hover {
  background-color: rgb(225, 226, 226);
}

.node-children {
  padding-left: 10px;
  width: 1fr;
}
</style>
