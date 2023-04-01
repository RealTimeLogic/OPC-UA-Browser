<script setup lang="ts">
import IconRealtimeLogic from './components/icons/IconRealtimeLogic.vue'
import ConnectForm from './components/ConnectForm.vue'
</script>

<template>
  <div class="opcua-client-app">
    <header>
      <div class="opcua-header">
        <ConnectForm/>
        <IconRealtimeLogic class="realtimelogic-header-logo"/>
      </div>
    </header>

    <aside>
      <div class="node-tree"> 
        <ua-node :root="root" :connected="connected" v-if="connected"/>
      </div>
    </aside>
<!-- 
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

<style>
body {
  margin: 0;
  padding: 0;

  font-family: Arial, Helvetica, sans-serif;
}

.opcua-client-app {
  display: flex;
  flex-direction: column;
}

header {
  position: fixed;
  display: flex;
  top: 0;
  left: 0;
  right: 0;
  height: 100px;
}

aside {
  position: fixed;
  display: flex;
  flex-direction: column;
  left: 0;
  top: 101px;
  bottom: 0;
  width: 300px;
  border-right: 1px solid lightgray;
  
  overflow: scroll;
}

main {
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

/* width */
::-webkit-scrollbar {
  width: 3mm;
  height: 3mm;
}

/* Track */
::-webkit-scrollbar-track {
  background: #f1f1f1;
}

::-webkit-scrollbar-track:hover {
  background: #e1e1e1;
}

/* Handle */
::-webkit-scrollbar-thumb {
  background: rgb(200, 200, 200);
}

/* Handle on hover */
::-webkit-scrollbar-thumb:hover {
  background: #97a7b7;
}


.opcua-header {
  width: 100%;
  height: 100%;
  display: flex;
  border-bottom: 1px solid silver;
  justify-content: space-between;
  align-items: center;
  background-image: linear-gradient(to bottom, #34495e, #2c3e50);
}

.realtimelogic-header-logo {
  height: 80%;
}

.endpoint-config-form {
  width: 280px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  padding-left: 10px;
  height: 90px;
}

.endpoint-select-row {
  display: flex;
  flex-direction: row;
  flex-wrap: nowrap;
}

.endpoint-url {
  flex-grow: 1;
}

.security-modes {
  display: flex;
  flex-direction: row;
  flex-wrap: nowrap;
}

.fill-endpoints-button {
  width: 20px;
  flex: 0;
  margin-left: 3px;
}

.endpoints-select {
  flex-grow: 1;
}

.connect-button {
}

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
  padding-left:10px;
  width: 1fr;
}

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


.ua-messages {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.ua-messages-top{
  border-top: 1px solid lightgray;
  border-bottom: 1px solid lightgray;
  padding: 2px;
  font-size: 8px;
}

.ua-messages-content {
  overflow: auto;
}

.ua-messages-table {
  flex: 1;
  border-collapse: collapse;
  padding: 0px;
  margin: 0px;
  font-size: 10px;
}

.ua-messages-tr {
  border-top: 1px solid lightgray;
}

.ua-messages-td {
  width: 10%;
  height: 12px;
}

.ua-messages-td-err {
  width: 10%;
  height: 12px;
  color: red;
}

.ua-login-component {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 100%;
  height: 100%;
  position: fixed;
  z-index: 100;
}

.ua-login-window {
  
}
</style>
