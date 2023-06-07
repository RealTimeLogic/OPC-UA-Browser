<script setup lang="ts">
import UaNode from './UaNode.vue'
import { uaApplication } from '../stores/UaState'
</script>

<template>
  <div class="aside-node">
    <div class="aside-title">
      <h5>OPC Tree</h5>
    </div>
    <div class="flex-column">
      <div v-if="uaApplication().connected" class="node-tree">
        <UaNode class="node-children" :root="uaApplication().root" />
      </div>
    </div>
  </div>
</template>

<style lang="scss">
.aside-node {
  max-height: #{calc(100vh - 180px)};
  overflow: auto;
}
.aside-title {
  padding: 10px;
}
.node-tree {
  padding: 5px;
  width: 100%;
  
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
  
}
</style>
