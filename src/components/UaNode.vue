<script setup lang="ts">

import { uaApplication } from '../stores/UaState'
import { inject } from "vue";

const props = defineProps(['root'])

function browse() {
    uaApplication().browse(props.root)
}

const selectNode: any = inject("selectNode")

</script>

<template>
    <div :ua-nodeid="root.nodeid" class="flex-column ua-node">
        <div class="node-row flex-row">
            <div class="node-plus" v-on:click.prevent="browse">{{ root.nodes.length == 0 ? "+" : "-" }}</div>
            <div class="node-name" v-on:click.prevent="selectNode(root.nodeid)">{{ root.label }}</div>
        </div>
        <UaNode class="node-children" v-for="(node, index) in root.nodes" :key="index" :root="node" />
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
