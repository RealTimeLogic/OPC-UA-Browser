<script setup lang="ts">
import { defineProps } from 'vue'
import * as OPCUA from 'opcua-client'

const props = defineProps(['attributes'])

function variantTypesToString(value: OPCUA.VariantTypes, type: OPCUA.VariantType): string {
  switch (type) {
  case OPCUA.VariantType.Null:
    return 'Null'
  case OPCUA.VariantType.Boolean:
    return value ? 'True' : 'False'
  case OPCUA.VariantType.SByte:
  case OPCUA.VariantType.Byte:
  case OPCUA.VariantType.Int16:
  case OPCUA.VariantType.UInt16:
  case OPCUA.VariantType.Int32:
  case OPCUA.VariantType.UInt32:
  case OPCUA.VariantType.Int64:
  case OPCUA.VariantType.UInt64:
  case OPCUA.VariantType.Float:
  case OPCUA.VariantType.Double:
  case OPCUA.VariantType.String:
  case OPCUA.VariantType.Guid:
  case OPCUA.VariantType.XmlElement:
  case OPCUA.VariantType.NodeId:
  case OPCUA.VariantType.ExpandedNodeId:
  case OPCUA.VariantType.StatusCode:
    return value?.toString() ?? ''

  case OPCUA.VariantType.ByteString: {
    const s = value as string
    return s ? btoa(s) : ''
  }
  case OPCUA.VariantType.DateTime:
    return new Date(value as number * 1000).toUTCString()

  case OPCUA.VariantType.QualifiedName: {
    const v = value as OPCUA.QualifiedName
    if (v.Ns) {
      return `${v.Ns}:${v.Name}`
    }
    return v.Name ?? ''
  }
  case OPCUA.VariantType.LocalizedText: {
    const v = value as OPCUA.LocalizedText
    if (v.Locale) {
      return `${v.Text} (${v.Locale})`
    }
    return v.Text ?? ''
  }
  case OPCUA.VariantType.ExtensionObject:
    return JSON.stringify(value, null, 2)
  case OPCUA.VariantType.DataValue:
    return attributeValueToString(value as OPCUA.DataValue)
  case OPCUA.VariantType.Variant:
    return attributeValueToString(value as OPCUA.DataValue)
  case OPCUA.VariantType.DiagnosticInfo:
    return JSON.stringify(value, null, 2)
  default:
    return JSON.stringify(value, null, 2)
  }
}

function attributeValueToString(value: OPCUA.DataValue): string {
  if (value.Value instanceof Array) {
    return (value.Value as OPCUA.VariantTypes[]).map(item => variantTypesToString(item, value.Type)).join('\n')
  }

  if (value.IsArray)
  {
    const v = value.Value as object
    if (Object.keys(v).length == 0)
      return '[]'
  }

  return variantTypesToString(value.Value, value.Type)
}

</script>

<template>
  <table class="table-node-attributes">
    <colgroup>
      <col style="width: 20%;" />
      <col style="width: auto" />
      <col style="width: 20%;" />
    </colgroup>
    <thead>
      <tr>
        <th>Value</th>
        <th>Attribute</th>
        <th>Type</th>
      </tr>
    </thead>
    <tbody>
      <tr v-for="(attr, index) in props.attributes" :key="index" class="node-attribute">
        <td class="node-attribute-name">{{ attr.name }}</td>
        <td class="node-attribute-value">
          <pre>{{ attributeValueToString(attr.value) }}</pre>
        </td>
        <td class="node-attribute-value">{{ attr.value?.Type ? OPCUA.variantTypeToString(attr.value.Type) : '' }}</td>
      </tr>
    </tbody>
  </table>
</template>

<style lang="scss">
.table-node-attributes {
  width: 100%;
  border-collapse: collapse;
  table-layout: fixed;
}

.table-node-attributes th,
.table-node-attributes td {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.resizable-th {
  position: relative;
  user-select: none;
}

.resize-handle {
  position: absolute;
  right: 0;
  top: 0;
  width: 6px;
  height: 100%;
  cursor: col-resize;
  z-index: 2;
  background: transparent;
}

.table-node-attributes col:nth-child(1) {
  width: 180px;
}
.table-node-attributes col:nth-child(3) {
  width: 220px;
}

.node-attribute {
  grid-template-columns: 200px 1fr;
  padding: 10px 5px;
  border-top: 1px solid lightgray;
  transition: all ease 0.2s;
  cursor: pointer;
  &:hover {
    background: #4f515c;
  }
}

.node-attribute-name {
  border-top: 0;
  border-bottom: 0;
  align-items: center;
  justify-content: flex-start;
  font-weight: bold;
}

.node-attribute-value {
  border-left: 1px solid lightgray;
  padding: 0 10px;
  border-top: 0;
  border-bottom: 0;
}
</style>
