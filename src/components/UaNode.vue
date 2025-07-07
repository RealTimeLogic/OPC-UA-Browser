<script setup lang="ts">
import { uaApplication } from '../stores/UaState'
import { inject, Ref } from 'vue'

const props = defineProps(['root'])

function browse() {
  uaApplication().browse(props.root)
}

const selectNode: Ref<(nodeId: string) => void> | undefined = inject('selectNode')
if (!selectNode) {
  throw new Error('selectNode is not defined')
}

</script>

<template>
  <div :ua-nodeid="root.nodeid" class="flex-column ua-node">
    <div class="node-row flex-row">
      <div class="node-plus" @click.prevent="browse">
        {{ root.nodes.length == 0 ? '+' : '-' }}
      </div>
      <div class="node-name" @click.prevent="selectNode(root.nodeid)">{{ root.label }}</div>
    </div>
    <UaNode v-for="(node, index) in root.nodes" :key="index" class="node-children" :root="node" />
  </div>
</template>

<style lang="scss">

  .node-children {
    position: relative;
    z-index: 1;
    padding-left: 10px;
    &::before {
      content: '';
      display: block;
      position: absolute;
      z-index: 2;
      width: 2px;
      height: 100%;
      background: transparent;
      top: 5px;
      left: 10px;
    }
    &:hover > .node-row > .node-name {
      background: #4f515c;
    }
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
    padding: 2px 5px;
    border-radius: 2px;
  }

  .node-name:hover {
    background-color: rgb(225, 255, 255);
  }

.node-children {
  padding-left: 10px;
  width: 1fr;
}
</style>
