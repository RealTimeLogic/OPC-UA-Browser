<script setup lang="ts">
import { defineProps } from 'vue'

const props = defineProps(['attributes'])
</script>

<template>
  <div>
    <table class="table-node-attributes">
      <tr v-for="(attr, index) in props.attributes" v-bind:key="index">
        <td class="td-node-attribute td-node-attribute-name">{{ attr.name }}</td>
        <td class="td-node-attribute td-node-attribute-value" style="text-align: left">
          <pre>{{ attr.value }}</pre>
        </td>
      </tr>
    </table>
  </div>
</template>

<style>
.table-node-attributes {
  width: 100%;
  /* border: 1px solid gray; */
  border-collapse: collapse;
}

.td-node-attribute {
  border: 1px solid gray;
  padding: 3px;
}
.td-node-attribute-name {
  width: 20%;
}

.td-node-attribute-value {
}
</style>
