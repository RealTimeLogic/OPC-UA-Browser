<script setup lang="ts">
import { watch, onUnmounted } from 'vue';
import { LogMessageType, uaApplication } from '../stores/UaState'

const messages = uaApplication().messages

const stopWatch = watch(messages, () => {
    const messagesDiv = document.getElementById("ua-messages")
    if (messagesDiv) {
      messagesDiv.scrollTop = messagesDiv.scrollHeight
    }
  },
  {flush: 'post'}
)

onUnmounted(() => {
  stopWatch() // Clean up the watcher when component is unmounted
})

function formatDate(date: Date) {
  return date.toLocaleDateString('en-US', { hour12: false, hour: '2-digit', minute: '2-digit', second: undefined })
}

function cleaMessages() {
  messages.splice(0, messages.length)
}

</script>
<template>
  <div class="ua-messages">
    <div class="ua-messages-top">
      <button type="button" class="btn btn-secondary btn-sm"
        style="--bs-btn-padding-y: .25rem; --bs-btn-padding-x: .5rem; --bs-btn-font-size: .75rem;"
        v-on:click.prevent="cleaMessages">
          Clear messages
      </button>
    </div>
    <div id="ua-messages" class="ua-messages-content">
        <div class="ua-messages-div"
          :class="{'ua-messages-div-err' : msg.type == LogMessageType.Error}"
          v-for="(msg, index) in messages" v-bind:key="index">
          <div class="ua-messaes-type" >
            <img v-if="msg.type == LogMessageType.Info" class="ua-message-icon" src="../assets/icon-info.svg" alt="Info"/>
            <img v-if="msg.type == LogMessageType.Error" class="ua-message-icon" src="../assets/icon-warning.svg" alt="Warning"/>
          </div>
          <div class="ua-messaes-message"> <pre>{{ msg.details }}</pre> </div>
          <div class="ua-messaes-time" > {{ formatDate(msg.time) }} </div>
        </div>
    </div>
  </div>
</template>

<style lang="scss">
.ua-messages {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.ua-messages-top {
  border-top: 1px solid #24262A;
  border-bottom: 1px solid #24262A;
  padding: 2px 20px;
  font-size: 8px;
  text-align: right;
}

.ua-messages-content {
  overflow: auto;
}

.ua-messages-div {
  display: grid;
  grid-template-columns: 30px auto 120px;
  grid-gap: 15px;
  padding: 5px 0;
  margin: 0px;
  border-collapse: collapse;
  font-size: 12px;
  align-items: center;
  background: #030329;
  border-top: 1px solid #525252;
  &.ua-messages-div-err {
    background: #504040;
  }

  .ua-messaes-type {
    justify-self: center;
  }

  .ua-message-icon {
    width: 15px;
    height: 15px;
  }

  pre {
    margin: 0;
  }
}

</style>