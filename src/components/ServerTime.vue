<script setup lang="ts">

const serverTime = defineProps(['serverTime'])

</script>

<template>
    <div>
        <span style="color: white">Server time: {{ serverTime.serverTime }}</span>
    </div>
</template>
