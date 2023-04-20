local ua = require("opcua.api")
local s = ua.StatusCode

local Boolean = "i=1"
local SByte = "i=2"
local Byte = "i=3"
local Int16 = "i=4"
local UInt16 = "i=5"
local Int32 = "i=6"
local UInt32 = "i=7"
local Int64 = "i=8"
local UInt64 = "i=9"
local Float = "i=10"
local Double = "i=11"
local String = "i=12"
local DateTime = "i=13"
local Guid = "i=14"
local ByteString = "i=15"
local XmlElement = "i=16"
local NodeId = "i=17"
local ExpandedNodeId = "i=18"
local StatusCode = "i=19"
local QualifiedName = "i=20"
local LocalizedText = "i=21"
local DataValue = "i=23"
local DiagnosticInfo = "i=25"
local Organizes = "i=35"
local BaseDataVariableType = "i=63"
local ObjectsFolder = "i=85"
local FolderType = "i=61"

local traceI = ua.trace.inf

local function addNodes(services, newVariable)
  local results = services:addNodes(newVariable)
  for i,res in ipairs(results) do
    if res.statusCode == ua.StatusCode.BadNodeIdExists then
      traceI(string.format("   Node '%s' with id '%s' already exists", newVariable.nodesToAdd[i].browseName.name, newVariable.nodesToAdd[i].requestedNewNodeId))
    elseif res.statusCode ~= ua.StatusCode.Good then
      traceE(string.format("Failed to add node '%s': 0x%X", newVariable.nodesToAdd[i].browseName.name, res.statusCode))
      error(resp.statusCode)
    else
      traceI(string.format("   AddedNodeId: %s", res.addedNodeId))
    end
  end
end

local startNodeId = 100000
local function nextId()
  startNodeId = startNodeId + 1
  return "i="..startNodeId
end


local function addBoolean(services, parentNodeId)
  if services.config.logging.services.infOn then
    traceI("Adding Boolean variable")
  end

  -- Array with node id attributes of a new boolean variable
  local newVariable = {
    nodesToAdd = {
      { -- #1
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="boolean_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="Boolean"},
        description = {text="Example of Boolean Scalar variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {boolean=true},
        dataType = Boolean,
        valueRank = -1,
        arrayDimensions = nil,
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      }
    }
  }

  addNodes(services, newVariable)
end

local function addBooleanArray(services, parentNodeId)
  traceI("Adding Boolean Array variable")

  -- Array with node id attributes of a new boolean variable
  local newVariable = {
    nodesToAdd = {
      { -- #1
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="boolean_array_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="BooleanArray"},
        description = {text="Example of Boolean Array variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {boolean={true,false,true,false,true,false,true,false,true,false}},
        dataType = Boolean,
        valueRank = ua.Types.ValueRank.OneDimension,
        arrayDimensions = {10},
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      }
    }
  }

  addNodes(services, newVariable)
end


local function addByte(services, parentNodeId)
  traceI("Adding Byte variable")

  -- Array with node id attributes of a new boolean variable
  local newVariable = {
    nodesToAdd = {
      { -- #1
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="byte_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="Byte"},
        description = {text="Example of Byte Scalar variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {byte=17},
        dataType = Byte,
        valueRank = -1,
        arrayDimensions = nil,
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      }
    }
  }

  addNodes(services, newVariable)
end


local function addByteArray(services, parentNodeId)
  traceI("Adding Byte Array variable")

  local data = {1,2,3,4,5,6,7,8,9,10}
  -- Array with node id attributes of a new boolean variable
  local newVariable = {
    nodesToAdd = {
      { -- #1
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="byte_array_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="ByteArray"},
        description = {text="Example of Byte Array variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {byte=data},
        dataType = Byte,
        valueRank = ua.Types.ValueRank.OneDimension,
        arrayDimensions = {#data},
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      }
    }
  }

  addNodes(services, newVariable)
end



local function addSByte(services, parentNodeId)
  traceI("Adding SByte variable")

  -- Array with node id attributes of a new boolean variable
  local newVariable = {
    nodesToAdd = {
      { -- #1
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="sbyte_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="SByte"},
        description = {text="Example of SByte scalar variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {sbyte=-100},
        dataType = SByte,
        valueRank = -1,
        arrayDimensions = nil,
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      }
    }
  }

  addNodes(services, newVariable)
end


local function addSByteArray(services, parentNodeId)
  traceI("Adding SByte Array variable")

  -- Array with node id attributes of a new boolean variable
  local newVariable = {
    nodesToAdd = {
      { -- #1
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="sbyte_array_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="SByteArray"},
        description = {text="Example of SByte array variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {sbyte={-2,-1,0,1,2,3,4,5,6,7}},
        dataType = SByte,
        valueRank = ua.Types.ValueRank.OneDimension,
        arrayDimensions = {10},
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      }
    }
  }

  addNodes(services, newVariable)
end


local function addInt16(services, parentNodeId)
  traceI("Adding Int16 variable")

  -- Array with node id attributes of a new boolean variable
  local newVariable = {
    nodesToAdd = {
      { -- #1
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="int16_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="Int16"},
        description = {text="Example of Int16 scalar variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {int16=30000},
        dataType = Int16,
        valueRank = -1,
        arrayDimensions = nil,
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      }
    }
  }

  addNodes(services, newVariable)
end

local function addInt16Array(services, parentNodeId)
  traceI("Adding Int16 Array variable")

  -- Array with node id attributes of a new boolean variable
  local newVariable = {
    nodesToAdd = {
      { -- #1
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="int16_array_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="Int16Array"},
        description = {text="Example of Int16 array variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {int16={-2000,-1000,0,100,200,300,400,5000,6000,7000}},
        dataType = Int16,
        valueRank = ua.Types.ValueRank.OneDimension,
        arrayDimensions = {10},
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      }
    }
  }

  addNodes(services, newVariable)
end



local function addUInt16_Scalar_And_Array(services, parentNodeId)
  traceI("Adding UInt16 variable and UInt16 array")

  -- Array with node id attributes of a new boolean variable
  local newVariable = {
    nodesToAdd = {
      { -- #1
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="uint16_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="UInt16"},
        description = {text="Example of UInt16 scalar variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {uint16=30000},
        dataType = UInt16,
        valueRank = -1,
        arrayDimensions = nil,
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      },
      { -- #2
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="uint16_array_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="UInt16Array"},
        description = {text="Example of UInt16 array variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {uint16={2000,1000,0,100,200,300,400,5000,6000,40000}},
        dataType = UInt16,
        valueRank = ua.Types.ValueRank.OneDimension,
        arrayDimensions = {10},
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      }

    }
  }

  addNodes(services, newVariable)
end


local function addInt32_UInt32_Scalar_And_Array(services, parentNodeId)
  traceI("Adding Int32,UInt32 scalar and array")

  -- Array with node id attributes of a new boolean variable
  local newVariable = {
    nodesToAdd = {
      { -- #1
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="uint32_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="UInt32"},
        description = {text="Example of UInt16 scalar variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {uint32=30000},
        dataType = UInt32,
        valueRank = -1,
        arrayDimensions = nil,
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      },
      { -- #2
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="uint32_array_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="UInt32Array"},
        description = {text="Example of UInt32 array variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {uint32={2000,1000,0,100,200,300,4000000,5000,6000,40000}},
        dataType = UInt32,
        valueRank = ua.Types.ValueRank.OneDimension,
        arrayDimensions = {10},
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      },
      { -- #3
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="int32_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="Int32"},
        description = {text="Example of Int32 scalar variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {int32=30000},
        dataType = Int32,
        valueRank = -1,
        arrayDimensions = nil,
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      },
      { -- #4
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="int32_array_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="Int32Array"},
        description = {text="Example of Int32 array variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {int32={-2000,1000,0,100,-200,300,-4000000,5000,6000,40000}},
        dataType = Int32,
        valueRank = ua.Types.ValueRank.OneDimension,
        arrayDimensions = {10},
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      }
    }
  }

  addNodes(services, newVariable)
end



local function addInt64_UInt64_Scalar_And_Array(services, parentNodeId)
  traceI("Adding Int64,UInt64 scalar and array")

  -- Array with node id attributes of a new boolean variable
  local newVariable = {
    nodesToAdd = {
      { -- #1
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="uint64_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="UInt64"},
        description = {text="Example of UInt64 scalar variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {uint64=3000000000},
        dataType = UInt64,
        valueRank = -1,
        arrayDimensions = nil,
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      },
      { -- #2
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="uint64_array_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="UInt64Array"},
        description = {text="Example of UInt64 array variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {uint64={2000,1000,0,100,200,300,4000000000,5000,6000,40000}},
        dataType = UInt64,
        valueRank = ua.Types.ValueRank.OneDimension,
        arrayDimensions = {10},
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      },
      { -- #3
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="int64_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="Int64"},
        description = {text="Example of Int64 scalar variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {int64=1000000000},
        dataType = Int64,
        valueRank = -1,
        arrayDimensions = nil,
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      },
      { -- #4
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="int64_array_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="Int64Array"},
        description = {text="Example of Int64 array variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {int64={-2000,1000,0,100,-200,300,-10000000000,5000,6000,40000}},
        dataType = Int64,
        valueRank = ua.Types.ValueRank.OneDimension,
        arrayDimensions = {10},
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      }
    }
  }

  addNodes(services, newVariable)
end


local function addFloat_Double_Scalar_And_Array(services, parentNodeId)
  traceI("Adding Float,Double scalar and array")

  -- Array with node id attributes of a new boolean variable
  local newVariable = {
    nodesToAdd = {
      { -- #1
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="float_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="Float"},
        description = {text="Example of Float scalar variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {float=3000000000},
        dataType = Float,
        valueRank = -1,
        arrayDimensions = nil,
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      },
      { -- #2
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="float_array_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="FloatArray"},
        description = {text="Example of Float array variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {float={0.1,-2.2,3.3,-4.4,5.5,6.6,-7.7,8.8,9.9,0}},
        dataType = Float,
        valueRank = ua.Types.ValueRank.OneDimension,
        arrayDimensions = {10},
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      },
      { -- #3
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="double_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="Double"},
        description = {text="Example of Double scalar variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {double=1000000000},
        dataType = Double,
        valueRank = -1,
        arrayDimensions = nil,
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      },
      { -- #4
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="double_array_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="DoubleArray"},
        description = {text="Example of Double array variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {double={-0.0,13.4,5,100.1,-12345679.123456789,987654321.123456789,-10000000000,5000,6000,40000}},
        dataType = Double,
        valueRank = ua.Types.ValueRank.OneDimension,
        arrayDimensions = {10},
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      }
    }
  }

  addNodes(services, newVariable)
end


local function addString_Scalar_And_Array(services, parentNodeId)
  traceI("Adding String scalar and array")

  -- Array with node id attributes of a new boolean variable
  local newVariable = {
    nodesToAdd = {
      { -- #1
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="string_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="String"},
        description = {text="String scalar variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {string="This is a string variable"},
        dataType = String,
        valueRank = -1,
        arrayDimensions = nil,
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      },
      { -- #2
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="string_array_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="StringArray"},
        description = {text="Example of String array variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {string={"Element1", "Element2", "Element3", "Element4", "Element5", "Element6", "Element7", "Element8", "Element9", "Element10"}},
        dataType = String,
        valueRank = ua.Types.ValueRank.OneDimension,
        arrayDimensions = {10},
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      },
    }
  }

  addNodes(services, newVariable)
end

local num = 0
local function genGuid()
  num = num + 1
  return {
    data1=num,
    data2=num,
    data3=num,
    data4=num,
    data5=num,
    data6=num,
    data7=num,
    data8=num,
    data9=num,
    data10=num,
    data11=num
  }
end
local function addGuid_Scalar_And_Array(services, parentNodeId)
  traceI("Adding Guid scalar and array")

  -- Array with node id attributes of a new variable
  local newVariable = {
    nodesToAdd = {
      { -- #1
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="guid_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="Guid"},
        description = {text="Guid scalar variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {guid=genGuid()},
        dataType = Guid,
        valueRank = -1,
        arrayDimensions = nil,
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      },
      { -- #2
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="guid_array_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="GuidArray"},
        description = {text="Example of Guid array variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {guid={genGuid(),genGuid(),genGuid(),genGuid(),genGuid(),genGuid(),genGuid(),genGuid(),genGuid(),genGuid()}},
        dataType = Guid,
        valueRank = ua.Types.ValueRank.OneDimension,
        arrayDimensions = {10},
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      },
    }
  }

  addNodes(services, newVariable)
end


local function addDateTime_Scalar_And_Array(services, parentNodeId)
  traceI("Adding DateTime scalar and array")

  local curTime = os.time()

  -- Array with node id attributes of a new variable
  local newVariable = {
    nodesToAdd = {
      { -- #1
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="datetime_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="DateTime"},
        description = {text="DateTime scalar variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {dateTime=curTime + 0.123},
        dataType = DateTime,
        valueRank = -1,
        arrayDimensions = nil,
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      },
      { -- #2
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="datetime_array_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="DateTimeArray"},
        description = {text="Example of DateTime array variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {dateTime={curTime,curTime+0.1,curTime+0.2,curTime+0.3,curTime+0.4,curTime+0.5,curTime+0.6,curTime+0.7,curTime+0.8,curTime+0.9}},
        dataType = DateTime,
        valueRank = ua.Types.ValueRank.OneDimension,
        arrayDimensions = {10},
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      },
    }
  }

  addNodes(services, newVariable)
end

local function addByteString_Scalar_And_Array(services, parentNodeId)
  traceI("Adding ByteString scalar and array")

  -- Array with node id attributes of a new boolean variable
  local newVariable = {
    nodesToAdd = {
      { -- #1
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="bytestring_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="ByteString"},
        description = {text="ByteString scalar variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {byteString={1,2,3,4,5,6,7,8,9}},
        dataType = ByteString,
        valueRank = -1,
        arrayDimensions = nil,
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      },
      { -- #2
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="bytestring_array_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="ByteStringArray"},
        description = {text="Example of ByteString array variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {byteString={{1,2,3,4,5}, {2,3,4,5,6,7}, {3,4,5,6,7}, {4,5,6,7,8,9}, {5,6,7,8,9}, {6,7,8,9}, {7,8,9,0}, {8,9,0}, {9,0}, {0}} },
        dataType = ByteString,
        valueRank = ua.Types.ValueRank.OneDimension,
        arrayDimensions = {10},
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      },
    }
  }

  addNodes(services, newVariable)
end


local function addXmlElement_Scalar_And_Array(services, parentNodeId)
  traceI("Adding XmlElement scalar and array")

  -- Array with node id attributes of a new boolean variable
  local newVariable = {
    nodesToAdd = {
      { -- #1
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="xmlelement_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="XmlElement"},
        description = {text="XmlElement scalar variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {xmlElement={value="asdfasdfasd"}},
        dataType = XmlElement,
        valueRank = -1,
        arrayDimensions = nil,
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      },
      { -- #2
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="xmlelement_array_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="XmlElementArray"},
        description = {text="Example of XmlElement array variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {xmlElement={
          {value="12345"},
          {value="23456"},
          {value="34678"},
          {value="4578"},
          {value="56899"},
          {value="2345234523"},
          {value='<xml version="1.0"><opcua></opcua>'},
          {value="7654"},
          {value="hmmm"},
          {value='123415546'}
        }},
        dataType = XmlElement,
        valueRank = ua.Types.ValueRank.OneDimension,
        arrayDimensions = {10},
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      },
    }
  }

  addNodes(services, newVariable)
end

local function addNodeId_Scalar_And_Array(services, parentNodeId)
  traceI("Adding NodeId scalar and array")

  -- Array with node id attributes of a new boolean variable
  local newVariable = {
    nodesToAdd = {
      { -- #1
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="nodeid_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="NodeId"},
        description = {text="NodeId scalar variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {nodeId="ns=10;s=string_id"},
        dataType = NodeId,
        valueRank = -1,
        arrayDimensions = nil,
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      },
      { -- #2
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="nodeid_array_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="NodeIdArray"},
        description = {text="Example of NodeId array variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {
          nodeId={
            "ns=11;s=string_id",
            "ns=1;i=10",
            "ns=2;i=9",
            "ns=3;i=8",
            "ns=4;i=7",
            "ns=5;i=6",
            "ns=6;i=5",
            "ns=7;i=4",
            "ns=8;i=3",
            "ns=9;i=2",
          }
        },
        dataType = NodeId,
        valueRank = ua.Types.ValueRank.OneDimension,
        arrayDimensions = {10},
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      },
    }
  }

  addNodes(services, newVariable)
end


local function addExpandedNodeId_Scalar_And_Array(services, parentNodeId)
  traceI("Adding ExpandedNodeId scalar and array")

  -- Array with node id attributes of a new boolean variable
  local newVariable = {
    nodesToAdd = {
      { -- #1
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="expanded_nodeid_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="ExpandedNodeId"},
        description = {text="ExpadedNodeId scalar variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {expandedNodeId="ns=10;s=expanded_string_id"},
        dataType = ExpandedNodeId,
        valueRank = -1,
        arrayDimensions = nil,
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      },
      { -- #2
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="expaded_nodeid_array_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="ExpandedNodeIdArray"},
        description = {text="Example of ExpandedNodeId array variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {
          expandedNodeId={
            "nsu=uri;s=expanded_string_id",
            "ns=1;i=10",
            "ns=2;i=9",
            "ns=3;i=8",
            "ns=4;i=7",
            "ns=5;i=6",
            "ns=6;i=5",
            "ns=7;i=4",
            "ns=8;i=3",
            "ns=9;i=2",
          }
        },
        dataType = ExpandedNodeId,
        valueRank = ua.Types.ValueRank.OneDimension,
        arrayDimensions = {10},
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      },
    }
  }

  addNodes(services, newVariable)
end


local function addStatusCode_Scalar_And_Array(services, parentNodeId)
  traceI("Adding Int32,UInt32 scalar and array")

  -- Array with node id attributes of a new boolean variable
  local newVariable = {
    nodesToAdd = {
      { -- #1
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="statuscode_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="StatusCode"},
        description = {text="Example of StatusCode scalar variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {statusCode=s.BadOutOfMemory},
        dataType = StatusCode,
        valueRank = -1,
        arrayDimensions = nil,
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      },
      { -- #2
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="statuscode_array_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="StatusCodeArray"},
        description = {text="Example of StatusCode array variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {statusCode={
          s.BadUnexpectedError,
          s.BadInternalError,
          s.BadOutOfMemory,
          s.BadResourceUnavailable,
          s.BadCommunicationError,
          s.BadEncodingError,
          s.BadDecodingError,
          s.BadEncodingLimitsExceeded,
          s.BadRequestTooLarge,
          s.BadResponseTooLarge
        }},
        dataType = StatusCode,
        valueRank = ua.Types.ValueRank.OneDimension,
        arrayDimensions = {10},
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      }
    }
  }

  addNodes(services, newVariable)
end


local function addQualifiedName_Scalar_And_Array(services, parentNodeId)
  traceI("Adding QualifiedName scalar and array")

  -- Array with node id attributes of a new QualifiedName variable
  local newVariable = {
    nodesToAdd = {
      { -- #1
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="qualifiedname_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="QualifiedName"},
        description = {text="Example of QualifiedName scalar variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {qualifiedName={name="QualifiedNameValue", ns=10}},
        dataType = QualifiedName,
        valueRank = -1,
        arrayDimensions = nil,
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      },
      { -- #2
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="qualifiedname_array_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="QualifiedNameArray"},
        description = {text="Example of QualifiedName array variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {qualifiedName={
          {name="QualifiedName1",ns=1},
          {name="QualifiedName2",ns=2},
          {name="QualifiedName3",ns=3},
          {name="QualifiedName4",ns=4},
          {name="QualifiedName5",ns=5},
          {name="QualifiedName6",ns=6},
          {name="QualifiedName7",ns=7},
          {name="QualifiedName8",ns=8},
          {name="QualifiedName9",ns=9},
          {name="QualifiedName10",ns=10},
        }},
        dataType = QualifiedName,
        valueRank = ua.Types.ValueRank.OneDimension,
        arrayDimensions = {10},
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      }
    }
  }

  addNodes(services, newVariable)
end


local function addLocalizedText_Scalar_And_Array(services, parentNodeId)
  traceI("Adding LocalizedText scalar and array")

  -- Array with node id attributes of a new QualifiedName variable
  local newVariable = {
    nodesToAdd = {
      { -- #1
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="localizedtext_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="LocalizedText"},
        description = {text="Example of LocalizedText scalar variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {localizedText={text="LocalizedTextScalar", locale="en-US"}},
        dataType = LocalizedText,
        valueRank = -1,
        arrayDimensions = nil,
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      },
      { -- #2
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="localizedtext_array_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="LocalizedTextArray"},
        description = {text="Example of LocalizedText array variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {localizedText={
          {text="LocalizedTextValue0", locale="en-US"},
          {text="LocalizedTextValue1", locale="en-US"},
          {text="LocalizedTextValue2", locale="en-US"},
          {text="LocalizedTextValue3", locale="en-US"},
          {text="LocalizedTextValue4", locale="en-US"},
          {text="LocalizedTextValue5", locale="en-US"},
          {text="LocalizedTextValue6", locale="en-US"},
          {text="LocalizedTextValue7", locale="en-US"},
          {text="LocalizedTextValue8", locale="en-US"},
          {text="LocalizedTextValue9", locale="en-US"},
        }},
        dataType = LocalizedText,
        valueRank = ua.Types.ValueRank.OneDimension,
        arrayDimensions = {10},
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      }
    }
  }

  addNodes(services, newVariable)
end


local function addExtensionObject_Scalar_And_Array(services, parentNodeId)
  traceI("Adding ExtensionObject scalar and array")

  -- Array with node id attributes of a new ExtensionObject variable
  local newVariable = {
    nodesToAdd = {
      { -- #1
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="extension_object_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="ExtensionObject"},
        description = {text="Example of ExtensionObject scalar variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {
          extensionObject={
            typeId="i=10000",
            body={1,2,3,4,5,6}
          }
        },
        dataType = Byte,
        valueRank = -1,
        arrayDimensions = nil,
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      },
      { -- #2
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="extension_object_array_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="ExtensionObjectArray"},
        description = {text="Example of ExtensionObject array variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {extensionObject={
          {typeId="i=10000",body={1,2,3,4,5,6}},
          {typeId="i=10000",body={1,2,3,4,5,6}},
          {typeId="i=10000",body={1,2,3,4,5,6}},
          {typeId="i=10000",body={1,2,3,4,5,6}},
          {typeId="i=10000",body={1,2,3,4,5,6}},
          {typeId="i=10000",body={1,2,3,4,5,6}},
          {typeId="i=10000",body={1,2,3,4,5,6}},
          {typeId="i=10000",body={1,2,3,4,5,6}},
          {typeId="i=10000",body={1,2,3,4,5,6}},
          {typeId="i=10000",body={1,2,3,4,5,6}},
        }},
        dataType = Byte,
        valueRank = ua.Types.ValueRank.OneDimension,
        arrayDimensions = {10},
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      }
    }
  }

  addNodes(services, newVariable)
end

local function addDataValue_Scalar_And_Array(services, parentNodeId)
  traceI("Adding DataValue scalar and array")

  -- Array with node id attributes of a new DataValue variable
  local newVariable = {
    nodesToAdd = {
      { -- #1
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="datavalue_object_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="DataValue"},
        description = {text="Example of DataValue scalar variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {
          dataValue={
            value={ byte=1 },
            statusCode = s.Good,
            sourceTimestamp = os.time() - 1,
            serverTimestamp = os.time(),
            sourcePicoseconds = 100,
            serverPicoseconds = 200
          }
        },
        dataType = DataValue,
        valueRank = -1,
        arrayDimensions = nil,
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      },
      { -- #2
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="datavalue_object_array_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="DataValueArray"},
        description = {text="Example of DataValue array variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {dataValue={
          {--#1
            value={ byte=1 },
            statusCode = s.Good,
            sourceTimestamp = os.time() - 1,
            serverTimestamp = os.time(),
            sourcePicoseconds = 100,
            serverPicoseconds = 200
          },
          {--#2
            value={ sbyte=1 },
            statusCode = s.Good,
            sourceTimestamp = os.time() - 1,
            serverTimestamp = os.time(),
            sourcePicoseconds = 100,
            serverPicoseconds = 200
          },
          {--#3
            value={ int16=1 },
            statusCode = s.Good,
            sourceTimestamp = os.time() - 1,
            serverTimestamp = os.time(),
            sourcePicoseconds = 100,
            serverPicoseconds = 200
          },
          {--#4
            value={ uint16=1 },
            statusCode = s.Good,
            sourceTimestamp = os.time() - 1,
            serverTimestamp = os.time(),
            sourcePicoseconds = 100,
            serverPicoseconds = 200
          },
          {--#5
            value={ double=1.1 },
            statusCode = s.Good,
            sourceTimestamp = os.time(),
            serverTimestamp = os.time() + 1,
            sourcePicoseconds = 100,
            serverPicoseconds = 200
          },
          {--#6
            value={ float=1.1 },
            statusCode = s.Good,
            sourceTimestamp = os.time(),
            serverTimestamp = os.time() + 1,
            sourcePicoseconds = 100,
            serverPicoseconds = 200
          },
          {--#7
            value={ uint64=122234567789},
            statusCode = s.Good,
            sourceTimestamp = os.time(),
            serverTimestamp = os.time() + 1,
            sourcePicoseconds = 100,
            serverPicoseconds = 200
          },
          {--#8
            value={ string="StringElement"},
            statusCode = s.Good,
            sourceTimestamp = os.time(),
            serverTimestamp = os.time() + 1,
            sourcePicoseconds = 100,
            serverPicoseconds = 200
          },
          {--#9
            value={ statusCode=s.BadInternalError},
            statusCode = s.Good,
            sourceTimestamp = os.time(),
            serverTimestamp = os.time() + 1,
            sourcePicoseconds = 100,
            serverPicoseconds = 200
          },
          {--#10
            value={ dateTime=os.time()},
            statusCode = s.Good,
            sourceTimestamp = os.time(),
            serverTimestamp = os.time() + 1,
            sourcePicoseconds = 100,
            serverPicoseconds = 200
          }
        }},
        dataType = DataValue,
        valueRank = ua.Types.ValueRank.OneDimension,
        arrayDimensions = {10},
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      }
    }
  }

  addNodes(services, newVariable)
end


local function addDiagnosticInfo_Scalar_And_Array(services, parentNodeId)
  traceI("Adding DiagnosticInfo scalar and array")

  -- Array with node id attributes of a new DataValue variable
  local newVariable = {
    nodesToAdd = {
      { -- #1
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="disgnosticinfo_object_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="DiagnosticInfo"},
        description = {text="Example of DiagnosticInfo scalar variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {
          diagnosticInfo = {
            symbolicId = -1,
            nsUri = -1,
            locale = -1,
            localizedText = -1,
            additionalInfo = "AdditionalInfo",
            innerStatusCode = s.BadNodeAttributesInvalid,
            innerDiagnosticInfo = {
              symbolicId = -1,
              nsUri = -1,
              locale = -1,
              localizedText = -1,
              additionalInfo = "InnerAdditionalInfo",
              innerStatusCode = s.BadNodeAttributesInvalid,
            }
          }
        },
        dataType = DiagnosticInfo,
        valueRank = ua.Types.ValueRank.Scalar,
        arrayDimensions = nil,
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      },
      { -- #2
        parentNodeId = parentNodeId,
        referenceTypeId = Organizes,
        requestedNewNodeId = nextId(),
        browseName = {name="diagnosticinfo_object_array_variable", ns=0},
        nodeClass = ua.Types.NodeClass.Variable,
        displayName = {text="DiagnosticInfoArray"},
        description = {text="Example of DiagnosticInfo array variable"},
        writeMask = 0,
        userWriteMask = 0,
        value = {
          diagnosticInfo={
            {--#1
              symbolicId = -1,
              nsUri = -1,
              locale = -1,
              localizedText = -1,
              additionalInfo = "AdditionalInfo1",
              innerStatusCode = s.BadNodeAttributesInvalid,
              innerDiagnosticInfo = {
                symbolicId = -1,
                nsUri = -1,
                locale = -1,
                localizedText = -1,
                additionalInfo = "InnerAdditionalInfo12",
                innerStatusCode = s.BadNodeAttributesInvalid,
              }
            },
            {--#2
              symbolicId = -1,
              nsUri = -1,
              locale = -1,
              localizedText = -1,
              additionalInfo = "AdditionalInfo2",
              innerStatusCode = s.BadNodeAttributesInvalid,
              innerDiagnosticInfo = {
                symbolicId = -1,
                nsUri = -1,
                locale = -1,
                localizedText = -1,
                additionalInfo = "InnerAdditionalInfo22",
                innerStatusCode = s.BadNodeAttributesInvalid,
              }
            },
            {--#3
              symbolicId = -1,
              nsUri = -1,
              locale = -1,
              localizedText = -1,
              additionalInfo = "AdditionalInfo3",
              innerStatusCode = s.BadNodeAttributesInvalid,
              innerDiagnosticInfo = {
                dymbolicId = -1,
                nsUri = -1,
                locale = -1,
                localizedText = -1,
                additionalInfo = "InnerAdditionalInfo32",
                innerStatusCode = s.BadNodeAttributesInvalid,
              }
            },
            {--#4
              symbolicId = -1,
              nsUri = -1,
              locale = -1,
              localizedText = -1,
              additionalInfo = "AdditionalInfo4",
              innerStatusCode = s.BadNodeAttributesInvalid,
              innerDiagnosticInfo = {
                symbolicId = -1,
                nsUri = -1,
                locale = -1,
                localizedText = -1,
                additionalInfo = "InnerAdditionalInfo42",
                innerStatusCode = s.BadNodeAttributesInvalid,
              }
            },
            {--#5
              symbolicId = -1,
              nsUri = -1,
              locale = -1,
              localizedText = -1,
              additionalInfo = "AdditionalInfo5",
              innerStatusCode = s.BadNodeAttributesInvalid,
              innerDiagnosticInfo = {
                symbolicId = -1,
                nsUri = -1,
                locale = -1,
                localizedText = -1,
                additionalInfo = "InnerAdditionalInfo52",
                innerStatusCode = s.BadNodeAttributesInvalid,
              }
            },
            {--#6
              symbolicId = -1,
              nsUri = -1,
              locale = -1,
              localizedText = -1,
              additionalInfo = "AdditionalInfo6",
              innerStatusCode = s.BadNodeAttributesInvalid,
              innerDiagnosticInfo = {
                symbolicId = -1,
                nsUri = -1,
                locale = -1,
                localizedText = -1,
                additionalInfo = "InnerAdditionalInfo62",
                innerStatusCode = s.BadNodeAttributesInvalid,
              }
            },
            {--#7
              symbolicId = -1,
              nsUri = -1,
              locale = -1,
              localizedText = -1,
              additionalInfo = "AdditionalInfo7",
              innerStatusCode = s.BadNodeAttributesInvalid,
              innerDiagnosticInfo = {
                symbolicId = -1,
                nsUri = -1,
                locale = -1,
                localizedText = -1,
                additionalInfo = "InnerAdditionalInfo72",
                innerStatusCode = s.BadNodeAttributesInvalid,
              }
            },
            {--#8
              symbolicId = -1,
              nsUri = -1,
              locale = -1,
              localizedText = -1,
              additionalInfo = "AdditionalInfo8",
              innerStatusCode = s.BadNodeAttributesInvalid,
              innerDiagnosticInfo = {
                symbolicId = -1,
                nsUri = -1,
                locale = -1,
                localizedText = -1,
                additionalInfo = "InnerAdditionalInfo82",
                innerStatusCode = s.BadNodeAttributesInvalid,
              }
            },
            {--#9
              symbolicId = -1,
              nsUri = -1,
              locale = -1,
              localizedText = -1,
              AdditionalInfo = "AdditionalInfo9",
              innerStatusCode = s.BadNodeAttributesInvalid,
              innerDiagnosticInfo = {
                symbolicId = -1,
                nsUri = -1,
                locale = -1,
                localizedText = -1,
                additionalInfo = "InnerAdditionalInfo92",
                innerStatusCode = s.BadNodeAttributesInvalid,
              }
            },
            {--#10
              symbolicId = -1,
              nsUri = -1,
              locale = -1,
              localizedText = -1,
              additionalInfo = "AdditionalInfo10",
              innerStatusCode = s.BadNodeAttributesInvalid,
              innerDiagnosticInfo = {
                symbolicId = -1,
                nsUri = -1,
                locale = -1,
                localizedText = -1,
                additionalInfo = "InnerAdditionalInfo102",
                innerStatusCode = s.BadNodeAttributesInvalid,
              }
            },
          }
        },
        dataType = DiagnosticInfo,
        valueRank = ua.Types.ValueRank.OneDimension,
        arrayDimensions = {10},
        accessLevel = 0,
        userAccessLevel = 0,
        minimumSamplingInterval = 1000,
        historizing = 0,
        typeDefinition = BaseDataVariableType
      }
    }
  }

  addNodes(services, newVariable)
end

local function addVaraibleFolder(services, parentNodeId)
  traceI("Adding folder 'Variables' under which variable nodes will be placed.")
  local folderId = nextId()
  local folderParams = {
    parentNodeId = ObjectsFolder,
    referenceTypeId = Organizes,
    requestedNewNodeId = folderId,
    browseName = {name="Variables", ns=3},
    nodeClass = ua.Types.NodeClass.Object,
    displayName = {text="Variables"},
    description = {text="Folder with different variables"},
    writeMask = 0,
    userWriteMask = 0,
    eventNotifier = 0,
    typeDefinition = FolderType
  }

  local request = {
    nodesToAdd = {folderParams}
  }

  local resp = services:addNodes(request)
  local res = resp.results
  if res[1].statusCode ~= ua.StatusCode.Good and res[1].statusCode ~= ua.StatusCode.BadNodeIdExists then
    error(res.statusCode)
  end

  return folderId
end

local function variables(services, parentNodeId)

  if services.config.logging.services.infOn then
    traceI = ua.trace.inf
  else
    traceI = function() end
  end

  local variablesFolderId = addVaraibleFolder(services, parentNodeId)
  addBoolean(services, variablesFolderId)
  addBooleanArray(services, variablesFolderId)
  addByte(services, variablesFolderId)
  addByteArray(services, variablesFolderId)
  addSByte(services, variablesFolderId)
  addSByteArray(services, variablesFolderId)
  addInt16(services, variablesFolderId)
  addInt16Array(services, variablesFolderId)
  addUInt16_Scalar_And_Array(services, variablesFolderId)
  addInt32_UInt32_Scalar_And_Array(services, variablesFolderId)
  addInt64_UInt64_Scalar_And_Array(services, variablesFolderId)
  addFloat_Double_Scalar_And_Array(services, variablesFolderId)
  addString_Scalar_And_Array(services, variablesFolderId)
  addByteString_Scalar_And_Array(services, variablesFolderId)
  addGuid_Scalar_And_Array(services, variablesFolderId)
  addDateTime_Scalar_And_Array(services, variablesFolderId)
  addXmlElement_Scalar_And_Array(services, variablesFolderId)
  addNodeId_Scalar_And_Array(services, variablesFolderId)
  addExpandedNodeId_Scalar_And_Array(services, variablesFolderId)
  addStatusCode_Scalar_And_Array(services, variablesFolderId)
  addQualifiedName_Scalar_And_Array(services, variablesFolderId)
  addLocalizedText_Scalar_And_Array(services, variablesFolderId)
  addExtensionObject_Scalar_And_Array(services, variablesFolderId)
  addDataValue_Scalar_And_Array(services, variablesFolderId)
  addDiagnosticInfo_Scalar_And_Array(services, variablesFolderId)
end

return variables
