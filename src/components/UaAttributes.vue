<script setup lang="ts">
import { defineProps } from 'vue'

const props = defineProps(['attributes'])
</script>

<template>
  <div class="div-node-attributes">
    <div v-for="(attr, index) in props.attributes" class="node-attribute"  v-bind:key="index">
      <div class="node-attribute-name">{{ attr.name }}</div>
      <div class="node-attribute-value" style="text-align: left">
        <pre>{{ attr.value }}</pre>
      </div>
    </div>
  </div>
</template>

<style lang="scss">
.table-node-attributes {
  width: 100%;
  /* border: 1px solid gray; */
  border-collapse: collapse;
}

.node-attribute {
  display: grid;
  grid-template-columns: 20% 1fr;
  padding: 10px 5px;
  border-top: 1px solid lightgray;
}

.node-attribute-name {
  border: 3px solid;
  border-image-slice: 1;
  border-image-source: linear-gradient(to top, transparent 0%, transparent 5%, #828efd 5.5%, #828efd 95%, transparent 95.5%);
  border-left: 0;
  border-top: 0;
  border-bottom: 0;
  align-items: center;
  justify-content: flex-start;
  font-weight: bold;
  display: grid;
  grid-template-columns: 1fr;
}
.node-attribute-value {
  padding-left: 10px;
  pre {
    margin: 0;
  }
}
</style>
