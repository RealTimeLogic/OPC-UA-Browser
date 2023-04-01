<script setup lang="ts">
import { LogMessageType, uaApplication } from '../stores/UaState'

const messages = uaApplication().messages

function cleaMessages() {
  messages.splice(0, messages.length)
}
</script>
<template>
  <div class="ua-messages">
    <div class="ua-messages-top">
      <button v-on:click.prevent="cleaMessages">Clear messages</button>
    </div>
    <div class="ua-messages-content">
      <table class="ua-messages-table">
        <tr class="ua-messages-tr" v-for="(msg, index) in messages" v-bind:key="index">
          <td :class="msg.type == LogMessageType.Error ? 'ua-messages-td-err' : 'ua-messages-td'">
            {{ msg.time }}
          </td>
          <td :class="msg.type == LogMessageType.Error ? 'ua-messages-td-err' : 'ua-messages-td'">
            {{ msg.type }}
          </td>
          <td :class="msg.type == LogMessageType.Error ? 'ua-messages-td-err' : 'ua-messages-td'">
            <pre>{{ msg.details }}</pre>
          </td>
        </tr>
      </table>
    </div>
  </div>
</template>

<style>
.ua-messages {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.ua-messages-top {
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
</style>
