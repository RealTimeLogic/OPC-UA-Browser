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
  local newVariable =
  {
    NodesToAdd = {
      ua.newVariableParams(parentNodeId, {Name="boolean_variable", ns=0}, "boolean_variable", {Value={Boolean=true}}, nextId())
    }
  }

  addNodes(services, newVariable)
end

local function addBooleanArray(services, parentNodeId)
  traceI("Adding Boolean Array variable")

  -- Array with node id attributes of a new boolean variable
  local newVariable = {
    NodesToAdd = {
      ua.newVariableParams(parentNodeId, {Name="boolean_array_variable", ns=0}, "BooleanArray", {Value={Boolean={true,false,true,false,true,false,true,false,true,false}}}, nextId())
    }
  }

  addNodes(services, newVariable)
end


local function addByte(services, parentNodeId)
  traceI("Adding Byte variable")

  -- Array with node id attributes of a new boolean variable
  local newVariable = {
    NodesToAdd = {
      ua.newVariableParams(parentNodeId, {Name="byte_variable", ns=0}, "Byte", {Value={Byte=17}}, nextId())
    }
  }

  addNodes(services, newVariable)
end


local function addByteArray(services, parentNodeId)
  traceI("Adding Byte Array variable")

  local data = {1,2,3,4,5,6,7,8,9,10}
  -- Array with node id attributes of a new boolean variable
  local newVariable = {
    NodesToAdd = {
      ua.newVariableParams(parentNodeId, {Name="byte_array_variable", ns=0}, "ByteArray", {Value={Byte=data}}, nextId())
    }
  }

  addNodes(services, newVariable)
end


local function addSByte(services, parentNodeId)
  traceI("Adding SByte variable")

  -- Array with node id attributes of a new boolean variable
  local newVariable = {
    NodesToAdd = {
      ua.newVariableParams(parentNodeId, {Name="sbyte_variable", ns=0}, "SByte", {Value={SByte=-100}}, nextId())
    }
  }

  addNodes(services, newVariable)
end


local function addSByteArray(services, parentNodeId)
  traceI("Adding SByte Array variable")

  -- Array with node id attributes of a new boolean variable
  local newVariable = {
    NodesToAdd = {
      ua.newVariableParams(parentNodeId, {Name="sbyte_array_variable", ns=0}, "SByteArray", {Value={SByte={-2,-1,0,1,2,3,4,5,6,7}}}, nextId())
    }
  }

  addNodes(services, newVariable)
end


local function addInt16(services, parentNodeId)
  traceI("Adding Int16 variable")

  -- Array with node id attributes of a new boolean variable
  local newVariable = {
    NodesToAdd = {
      ua.newVariableParams(parentNodeId, {Name="int16_variable", ns=0}, "Int16", {Value={Int16=30000}}, nextId())
    }
  }

  addNodes(services, newVariable)
end

local function addInt16Array(services, parentNodeId)
  traceI("Adding Int16 Array variable")

  -- Array with node id attributes of a new boolean variable
  local newVariable = {
    NodesToAdd = {
      ua.newVariableParams(parentNodeId, {Name="int16_array_variable", ns=0}, "Int16Array", {Value={Int16={-2000,-1000,0,100,200,300,400,5000,6000,7000}}}, nextId())
    }
  }

  addNodes(services, newVariable)
end



local function addUInt16_Scalar_And_Array(services, parentNodeId)
  traceI("Adding UInt16 variable and UInt16 array")

  -- Array with node id attributes of a new boolean variable
  local newVariable = {
    NodesToAdd = {
      ua.newVariableParams(parentNodeId, {Name="uint16_variable", ns=0}, "UInt16", {Value={UInt16=30000}}, nextId()),
      ua.newVariableParams(parentNodeId, {Name="uint16_array_variable", ns=0}, "UInt16Array", {Value={UInt16={2000,1000,0,100,200,300,400,5000,6000,40000}}}, nextId())
    }
  }

  addNodes(services, newVariable)
end


local function addInt32_UInt32_Scalar_And_Array(services, parentNodeId)
  traceI("Adding Int32,UInt32 scalar and array")

  -- Array with node id attributes of a new boolean variable
  local newVariable = {
    NodesToAdd = {
      ua.newVariableParams(parentNodeId, {Name="uint32_variable", ns=0}, "UInt32", {Value={UInt32=30000}}, nextId()),
      ua.newVariableParams(parentNodeId, {Name="uint32_array_variable", ns=0}, "UInt32Array", {Value={UInt32={2000,1000,0,100,200,300,4000000,5000,6000,40000}}}, nextId()),
      ua.newVariableParams(parentNodeId, {Name="int32_variable", ns=0}, "Int32", {Value={Int32=30000}}, nextId()),
      ua.newVariableParams(parentNodeId, {Name="int32_array_variable", ns=0}, "Int32Array", {Value={Int32={-2000,1000,0,100,-200,300,-4000000,5000,6000,40000}}}, nextId())
    }
  }

  addNodes(services, newVariable)
end



local function addInt64_UInt64_Scalar_And_Array(services, parentNodeId)
  traceI("Adding Int64,UInt64 scalar and array")

  -- Array with node id attributes of a new boolean variable
  local newVariable = {
    NodesToAdd = {
      ua.newVariableParams(parentNodeId, {Name="uint64_variable", ns=0}, "UInt64", {Value={UInt64=3000000000}}, nextId()),
      ua.newVariableParams(parentNodeId, {Name="uint64_array_variable", ns=0}, "UInt64Array", {Value={UInt64={2000,1000,0,100,200,300,4000000000,5000,6000,40000}}}, nextId()),
      ua.newVariableParams(parentNodeId, {Name="int64_variable", ns=0}, "Int64", {Value={Int64=1000000000}}, nextId()),
      ua.newVariableParams(parentNodeId, {Name="int64_array_variable", ns=0}, "Int364Array", {Value={Int64={-2000,1000,0,100,-200,300,-10000000000,5000,6000,40000}}}, nextId())
    }
  }

  addNodes(services, newVariable)
end


local function addFloat_Double_Scalar_And_Array(services, parentNodeId)
  traceI("Adding Float,Double scalar and array")

  -- Array with node id attributes of a new boolean variable
  local newVariable = {
    NodesToAdd = {
      ua.newVariableParams(parentNodeId, {Name="float_variable", ns=0}, "Float", {Value={Float=1.1}}, nextId()),
      ua.newVariableParams(parentNodeId, {Name="float_array_variable", ns=0}, "FloatArray", {Value={Float={2.2,3.3}}}, nextId()),
      ua.newVariableParams(parentNodeId, {Name="double_variable", ns=0}, "Double", {Value={Double=-1.1}}, nextId()),
      ua.newVariableParams(parentNodeId, {Name="double_array_variable", ns=0}, "Double", {Value={Double={6000.222,40000.22}}}, nextId())
    }
  }

  addNodes(services, newVariable)
end


local function addString_Scalar_And_Array(services, parentNodeId)
  traceI("Adding String scalar and array")

  -- Array with node id attributes of a new boolean variable
  local strScalar = "This is a string variable"
  local strArray = {"Element1", "Element2", "Element3", "Element4", "Element5", "Element6", "Element7", "Element8", "Element9", "Element10"}
  local newVariable = {
    NodesToAdd = {
      ua.newVariableParams(parentNodeId, {Name="string_variable", ns=0}, "String", {Value={String=strScalar}}, nextId()),
      ua.newVariableParams(parentNodeId, {Name="string_array_variable", ns=0}, "StringArray", {Value={String=strArray}}, nextId()),
    }
  }

  addNodes(services, newVariable)
end

local num = 0
local function genGuid()
  num = num + 1
  return {
    Data1=num,
    Data2=num,
    Data3=num,
    Data4=num,
    Data5=num,
    Data6=num,
    Data7=num,
    Data8=num,
    Data9=num,
    Data10=num,
    Data11=num
  }
end
local function addGuid_Scalar_And_Array(services, parentNodeId)
  traceI("Adding Guid scalar and array")

  local guidScalar = genGuid()
  local guidArray = {genGuid(),genGuid(),genGuid()}
  -- Array with node id attributes of a new variable
  local newVariable = {
    NodesToAdd = {
      ua.newVariableParams(parentNodeId, {Name="guid_variable", ns=0}, "Guid", {Value={Guid=guidScalar}}, nextId()),
      ua.newVariableParams(parentNodeId, {Name="guid_array_variable", ns=0}, "GuidArray", {Value={Guid=guidArray}}, nextId())
    }
  }

  addNodes(services, newVariable)
end


local function addDateTime_Scalar_And_Array(services, parentNodeId)
  traceI("Adding DateTime scalar and array")

  local curTime = os.time()
  local dateTimeScalar = curTime + 0.123
  local dateTimeArray = {curTime, curTime - 1, curTime - 2, curTime - 3, curTime - 4, curTime - 5, curTime - 6, curTime - 7, curTime - 8, curTime - 9}
  -- Array with node id attributes of a new variable
  local newVariable = {
    NodesToAdd = {
      ua.newVariableParams(parentNodeId, {Name="datetime_variable", ns=0}, "DateTime", {Value={DateTime=dateTimeScalar}}, nextId()),
      ua.newVariableParams(parentNodeId, {Name="datetime_array_variable", ns=0}, "DateTimeArray", {Value={DateTime=dateTimeArray}}, nextId())
    }
  }

  addNodes(services, newVariable)
end

local function addByteString_Scalar_And_Array(services, parentNodeId)
  traceI("Adding ByteString scalar and array")

  local byteStringScalar = {1,2,3,4,5,6,7,8,9}
  local byteStringArray = {
    {1,2,3,4,5},
    {2,3,4,5,6,7},
    {3,4,5,6,7},
    {4,5,6,7,8,9},
    {5,6,7,8,9},
    {6,7,8,9},
    {7,8,9,0},
    {8,9,0},
    {9,0},
    {0}
  }
  -- Array with node id attributes of a new boolean variable
  local newVariable = {
    NodesToAdd = {
      ua.newVariableParams(parentNodeId, {Name="bytestring_variable", ns=0}, "ByteString", {Value={ByteString=byteStringScalar}}, nextId()),
      ua.newVariableParams(parentNodeId, {Name="datetime_array_variable", ns=0}, "DateTimeArray", {Value={ByteString=byteStringArray}}, nextId())
    }
  }

  addNodes(services, newVariable)
end


local function addXmlElement_Scalar_And_Array(services, parentNodeId)
  traceI("Adding XmlElement scalar and array")

  local xmlScalar = {
    Value = '<xml version="1.0"><opcua></opcua>'
  }
  local xmlArray = {
      {Value="12345"},
      {Value="23456"},
      {Value="34678"},
      {Value="4578"},
      {Value="56899"},
      {Value="2345234523"},
      {Value='<xml version="1.0"><opcua></opcua>'},
      {Value="7654"},
      {Value="hmmm"},
      {Value='123415546'}
    }

  -- Array with node id attributes of a new boolean variable
  local newVariable = {
    NodesToAdd = {
      ua.newVariableParams(parentNodeId, {Name="xmlelement_variable", ns=0}, "XmlElement", {Value={XmlElement=xmlScalar}}, nextId()),
      ua.newVariableParams(parentNodeId, {Name="xmlelement_array_variable", ns=0}, "XmlElementArray", {Value={XmlElement=xmlArray}}, nextId()),
    }
  }

  addNodes(services, newVariable)
end

local function addNodeId_Scalar_And_Array(services, parentNodeId)
  traceI("Adding NodeId scalar and array")

  local nodeIdScalar = "ns=10;s=string_id"
  local nodeIdArray = {
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

  -- Array with node id attributes of a new boolean variable
  local newVariable = {
    NodesToAdd = {
      ua.newVariableParams(parentNodeId, {Name="nodeid_variable", ns=0}, "NodeId", {Value={NodeId=nodeIdScalar}}, nextId()),
      ua.newVariableParams(parentNodeId, {Name="nodeid_array_variable", ns=0}, "NodeIdArray", {Value={NodeId=nodeIdArray}}, nextId()),
    }
  }

  addNodes(services, newVariable)
end


local function addExpandedNodeId_Scalar_And_Array(services, parentNodeId)
  traceI("Adding ExpandedNodeId scalar and array")


  local nodeIdScalar = "ns=10;s=expanded_string_id"
  local nodeIdArray = {
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

  -- Array with node id attributes of a new boolean variable
  local newVariable = {
    NodesToAdd = {
      ua.newVariableParams(parentNodeId, {Name="expanded_nodeid_variable", ns=0}, "ExpandedNodeId", {Value={ExpandedNodeId=nodeIdScalar}}, nextId()),
      ua.newVariableParams(parentNodeId, {Name="expanded_nodeid_array_variable", ns=0}, "ExpandedNodeIdArray", {Value={ExpandedNodeId=nodeIdArray}}, nextId()),
    }
  }

  addNodes(services, newVariable)
end


local function addStatusCode_Scalar_And_Array(services, parentNodeId)
  traceI("Adding StatusCode variables scalar and array")

  local statusCodeScalar = s.BadOutOfMemory
  local statusCodeArray = {
    s.BadOutOfMemory,
    s.BadNodeIdExists,
    s.BadNodeIdUnknown,
    s.BadAttributeIdInvalid,
    s.BadUserAccessDenied,
    s.BadNotWritable,
    s.BadNotReadable,
    s.BadInvalidArgument,
    s.BadInvalidNodeId,
    s.BadInvalidArgument
  }

  -- Array with node id attributes of a new boolean variable
  local newVariable = {
    NodesToAdd = {
      ua.newVariableParams(parentNodeId, {Name="statuscode_variable", ns=0}, "StatusCode", {Value={StatusCode=statusCodeScalar}}, nextId()),
      ua.newVariableParams(parentNodeId, {Name="statuscode_array_variable", ns=0}, "StatusCodeArray", {Value={StatusCode=statusCodeArray}}, nextId()),
    }
  }

  addNodes(services, newVariable)
end


local function addQualifiedName_Scalar_And_Array(services, parentNodeId)
  traceI("Adding QualifiedName scalar and array")

  local qualifiedNameScalar = {Name="QualifiedNameValue", ns=10}
  local qualifiedNameArray = {
    {Name="QualifiedName1",ns=1},
    {Name="QualifiedName2",ns=2},
    {Name="QualifiedName3",ns=3},
    {Name="QualifiedName4",ns=4},
    {Name="QualifiedName5",ns=5},
    {Name="QualifiedName6",ns=6},
    {Name="QualifiedName7",ns=7},
    {Name="QualifiedName8",ns=8},
    {Name="QualifiedName9",ns=9},
    {Name="QualifiedName10",ns=10},
  }

  -- Array with node id attributes of a new QualifiedName variable
  local newVariable = {
    NodesToAdd = {
      ua.newVariableParams(parentNodeId, {Name="qualifiedname_variable", ns=0}, "QualifiedName", {Value={QualifiedName=qualifiedNameScalar}}, nextId()),
      ua.newVariableParams(parentNodeId, {Name="qualifiedname_array_variable", ns=0}, "QualifiedNameArray", {Value={QualifiedName=qualifiedNameArray}}, nextId()),
    }
  }

  addNodes(services, newVariable)
end


local function addLocalizedText_Scalar_And_Array(services, parentNodeId)
  traceI("Adding LocalizedText scalar and array")

  local localizedTextScalar = {Text="LocalizedTextValue", Locale="en-US"}
  local localizedTextArray = {
    {Text="LocalizedTextValue0", Locale="en-US"},
    {Text="LocalizedTextValue1", Locale="en-US"},
    {Text="LocalizedTextValue2", Locale="en-US"},
    {Text="LocalizedTextValue3", Locale="en-US"},
    {Text="LocalizedTextValue4", Locale="en-US"},
    {Text="LocalizedTextValue5", Locale="en-US"},
    {Text="LocalizedTextValue6", Locale="en-US"},
    {Text="LocalizedTextValue7", Locale="en-US"},
    {Text="LocalizedTextValue8", Locale="en-US"},
    {Text="LocalizedTextValue9", Locale="en-US"},
  }

  -- Array with node id attributes of a new QualifiedName variable
  local newVariable = {
    NodesToAdd = {
      ua.newVariableParams(parentNodeId, {Name="localizedtext_variable", ns=0}, "LocalizedText", {Value={LocalizedText=localizedTextScalar}}, nextId()),
      ua.newVariableParams(parentNodeId, {Name="localizedtext_array_variable", ns=0}, "LocalizedTextArray", {Value={LocalizedText=localizedTextArray}}, nextId()),
    }
  }

  addNodes(services, newVariable)
end


local function addExtensionObject_Scalar_And_Array(services, parentNodeId)
  traceI("Adding ExtensionObject scalar and array")

  local extensionObjectScalar = {
    TypeId="i=10000",
    Body={1,2,3,4,5,6}
  }

  local extensionObjectArray = {
    {TypeId="i=10000",Body={1,2,3,4,5,6}},
    {TypeId="i=10000",Body={1,2,3,4,5,6}},
    {TypeId="i=10000",Body={1,2,3,4,5,6}},
    {TypeId="i=10000",Body={1,2,3,4,5,6}},
    {TypeId="i=10000",Body={1,2,3,4,5,6}},
    {TypeId="i=10000",Body={1,2,3,4,5,6}},
    {TypeId="i=10000",Body={1,2,3,4,5,6}},
    {TypeId="i=10000",Body={1,2,3,4,5,6}},
    {TypeId="i=10000",Body={1,2,3,4,5,6}},
    {TypeId="i=10000",Body={1,2,3,4,5,6}},
  }


  -- Array with node id attributes of a new ExtensionObject variable
  local newVariable = {
    NodesToAdd = {
      ua.newVariableParams(parentNodeId, {Name="extension_object_variable", ns=0}, "ExtensionObject", {Value={ExtensionObject=extensionObjectScalar}}, nextId()),
      ua.newVariableParams(parentNodeId, {Name="extension_object_array_variable", ns=0}, "ExtensionObjectArray", {Value={ExtensionObject=extensionObjectArray}}, nextId())
    }
  }

  addNodes(services, newVariable)
end

local function addDataValue_Scalar_And_Array(services, parentNodeId)
  traceI("Adding DataValue scalar and array")

  local dataValueScalar = {
    Value={ Byte=1 },
    StatusCode = s.Good,
    SourceTimestamp = os.time() - 1,
    ServerTimestamp = os.time(),
    SourcePicoseconds = 100,
    ServerPicoseconds = 200
  }

  local dataValueArray = {
    {--#1
      Value={ Byte=1 },
      StatusCode = s.Good,
      SourceTimestamp = os.time() - 1,
      ServerTimestamp = os.time(),
      SourcePicoseconds = 100,
      ServerPicoseconds = 200
    },
    {--#2
      Value={ SByte=1 },
      StatusCode = s.Good,
      SourceTimestamp = os.time() - 1,
      ServerTimestamp = os.time(),
      SourcePicoseconds = 100,
      ServerPicoseconds = 200
    },
    {--#3
      Value={ Int16=1 },
      StatusCode = s.Good,
      SourceTimestamp = os.time() - 1,
      ServerTimestamp = os.time(),
      SourcePicoseconds = 100,
      ServerPicoseconds = 200
    },
    {--#4
      Value={ UInt16=1 },
      StatusCode = s.Good,
      SourceTimestamp = os.time() - 1,
      ServerTimestamp = os.time(),
      SourcePicoseconds = 100,
      ServerPicoseconds = 200
    },
    {--#5
      Value={ Double=1.1 },
      StatusCode = s.Good,
      SourceTimestamp = os.time(),
      ServerTimestamp = os.time() + 1,
      SourcePicoseconds = 100,
      ServerPicoseconds = 200
    },
    {--#6
      Value={ Float=1.1 },
      StatusCode = s.Good,
      SourceTimestamp = os.time(),
      ServerTimestamp = os.time() + 1,
      SourcePicoseconds = 100,
      ServerPicoseconds = 200
    },
    {--#7
      Value={ UInt64=122234567789},
      StatusCode = s.Good,
      SourceTimestamp = os.time(),
      ServerTimestamp = os.time() + 1,
      SourcePicoseconds = 100,
      ServerPicoseconds = 200
    },
    {--#8
      Value={ String="StringElement"},
      StatusCode = s.Good,
      SourceTimestamp = os.time(),
      ServerTimestamp = os.time() + 1,
      SourcePicoseconds = 100,
      ServerPicoseconds = 200
    },
    {--#9
      Value={ StatusCode=s.BadInternalError},
      StatusCode = s.Good,
      SourceTimestamp = os.time(),
      ServerTimestamp = os.time() + 1,
      SourcePicoseconds = 100,
      ServerPicoseconds = 200
    },
    {--#10
      Value={ DateTime=os.time()},
      StatusCode = s.Good,
      SourceTimestamp = os.time(),
      ServerTimestamp = os.time() + 1,
      SourcePicoseconds = 100,
      ServerPicoseconds = 200
    }
  }

  -- Array with node id attributes of a new DataValue variable
  local newVariable = {
    NodesToAdd = {
      ua.newVariableParams(parentNodeId, {Name="datavalue_object_variable", ns=0}, "DataValue", {Value={DataValue=dataValueScalar}}, nextId()),
      ua.newVariableParams(parentNodeId, {Name="datavalue_object_array_variable", ns=0}, "DataValueArray", {Value={DataValue=dataValueArray}}, nextId()),
    }
  }

  addNodes(services, newVariable)
end


local function addDiagnosticInfo_Scalar_And_Array(services, parentNodeId)
  traceI("Adding DiagnosticInfo scalar and array")

  local diagnosticInfoScalar = {
    SymbolicId = -1,
    NsUri = -1,
    Locale = -1,
    LocalizedText = -1,
    AdditionalInfo = "AdditionalInfo",
    InnerStatusCode = s.BadNodeAttributesInvalid,
    InnerDiagnosticInfo = {
      SymbolicId = -1,
      NsUri = -1,
      Locale = -1,
      LocalizedText = -1,
      AdditionalInfo = "InnerAdditionalInfo",
      InnerStatusCode = s.BadNodeAttributesInvalid,
    }
  }

  local diagnosticInfoArray = {
    diagnosticInfoScalar,
    diagnosticInfoScalar,
    diagnosticInfoScalar,
    diagnosticInfoScalar,
    diagnosticInfoScalar,
    diagnosticInfoScalar,
    diagnosticInfoScalar,
    diagnosticInfoScalar,
  }

  -- Array with node id attributes of a new DataValue variable
  local newVariable = {
    NodesToAdd = {
      ua.newVariableParams(parentNodeId, {Name="disgnosticinfo_object_variable", ns=0}, "DiagnosticInfo", {Value={DiagnosticInfo=diagnosticInfoScalar}}, nextId()),
      ua.newVariableParams(parentNodeId, {Name="diagnosticinfo_object_array_variable", ns=0}, "DiagnosticInfoArray", {Value={DiagnosticInfo=diagnosticInfoArray}}, nextId()),
    }
  }

  addNodes(services, newVariable)
end

local function addVaraibleFolder(services, parentNodeId)
  traceI("Adding folder 'Variables' under which variable nodes will be placed.")
  local folderId = nextId()
  local folderParams = ua.newFolderParams(parentNodeId, {Name="Variables", ns=0}, "Variables", folderId)
  local request = {
    NodesToAdd = {folderParams}
  }

  local resp = services:addNodes(request)
  local res = resp.Results
  if res[1].StatusCode ~= ua.StatusCode.Good and res[1].StatusCode ~= ua.StatusCode.BadNodeIdExists then
    error(res.StatusCode)
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
  addGuid_Scalar_And_Array(services, variablesFolderId)
  addDateTime_Scalar_And_Array(services, variablesFolderId)
  addByteString_Scalar_And_Array(services, variablesFolderId)
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
