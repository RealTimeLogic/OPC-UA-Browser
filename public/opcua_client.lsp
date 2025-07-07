<?lsp

local ua = require("opcua.api")

local fmt = string.format
local traceD = ua.trace.dbg
local traceI = ua.trace.inf
local traceE = ua.trace.err

local function isSupportedPolicy(policyUri)
  for _,policy in ipairs(clientConfig.securePolicies) do
    if policy.securityPolicyUri == policyUri then
      return true
    end
  end
end

local function isSupportedTokenType(userTokenPolicy)
   local type = userTokenPolicy.TokenType
   local policyUri = userTokenPolicy.SecurityPolicyUri
   traceD(fmt("Check for token policy support: type='%s', policyUri='%s'", type, policyUri))
   local supported = false
   if type == ua.UserTokenType.Anonymous then
      supported = true
   elseif type == ua.UserTokenType.Certificate then
      supported = policyUri == nil or isSupportedPolicy(policyUri)
   elseif type == ua.UserTokenType.UserName then
      supported = policyUri == nil or isSupportedPolicy(policyUri)
   end

   if supported then
      traceD(fmt("Supported token policy: type='%s', policyUri='%s'", type, policyUri))
   else
      traceD(fmt("Unsupported token policy: type='%s', policyUri='%s'", type, policyUri))
   end

   return supported
end

local function opcUaClient(wsSock)
   local ok,uaClient
   local js = require("JSONS").create({}, wsSock)
   while true do
      local request, err = js:get()
      if not request then
         tracep(false, 1, "ERROR: Failed to read Request: ", err)
         break
      end

      if not request.id then
         tracep(false, 1, "ERROR: Request has no 'id': ", data)
         break
      end

      local resp = { id = request and request.id }
      if request then
         if request.ConnectEndpoint then
            traceI("Received Connect request")
            local endpointUrl = request.ConnectEndpoint.EndpointUrl
            if endpointUrl then
               if uaClient then
                  traceI("Closing UA client")
                  pcall(function()
                     uaClient:closeSession()
                     uaClient:disconnect()
                  end)
               end
               traceI("Creating new UA client")
               clientConfig.cosocketMode = true
               ua.Tools.printTable("Client configuration", clientConfig, ua.trace.dbg)
               -- Cosocket mode will automatically be enabled since are we in cosocket context
               uaClient = ua.newClient(clientConfig)
               traceI("Connecting to endpoint '".. endpointUrl .. "' transportProfileUri: '" .. (request.ConnectEndpoint.TransportProfileUri or "") .. "'")
               local result = uaClient:connect(endpointUrl, request.ConnectEndpoint.TransportProfileUri)
               if result then
                  uaClient = nil
                  traceI(fmt("Connection failed: ", result))
                  resp.Error = result
               else
                  traceI("Connected")
               end
            else
               traceE("Error: client sent empty endpoint URL")
               resp.Error = "Empty endpointURL"
            end
         else
            if not uaClient then
               traceE("Error: OPCUA request without calling connectEndpoint")
               resp.Error = "OPC UA Client not connected"
            elseif request.OpenSecureChannel then
              traceI("Opening secureChannel")
              local timeoutMs = request.OpenSecureChannel.TimeoutMs or 3600000
              local securityPolicyUri = request.OpenSecureChannel.SecurityPolicyUri or ua.SecurityPolicy.None
              local securityMode = request.OpenSecureChannel.SecurityMode or ua.MessageSecurityMode.None
              local serverCertificate = request.OpenSecureChannel.ServerCertificate
              if serverCertificate == ba.json.null then
               serverCertificate = nil
              elseif serverCertificate then
                serverCertificate = ba.b64decode(serverCertificate)
              end
              resp.Data, resp.Error = uaClient:openSecureChannel(timeoutMs, securityPolicyUri, securityMode, serverCertificate)
              if resp.Data then
                 if resp.Data.ServerNonce then
                   resp.Data.ServerNonce = ba.b64encode(resp.Data.ServerNonce)
                 end
              end
            elseif request.CloseSecureChannel then
              traceI("Closing Secure Channel")
              resp.Error = uaClient:closeSecureChannel()
            elseif request.CreateSession then
              traceI("Creating Session")
              local sessionName = request.CreateSession.SessionName
              local sessionTimeout = request.CreateSession.SessionTimeout
              resp.Data, resp.Error = uaClient:createSession(sessionName, sessionTimeout)
              if resp.Error then
               resp.Data = nil
              else
                for _, endpoint in ipairs(resp.Data.ServerEndpoints) do
                  if endpoint.ServerCertificate then
                    endpoint.ServerCertificate = ba.b64encode(endpoint.ServerCertificate)
                  end
                end
                if resp.Data.ServerSignature.Signature then
                  resp.Data.ServerSignature.Signature = ba.b64encode(resp.Data.ServerSignature.Signature)
                end

                if resp.Data.ServerCertificate then
                  resp.Data.ServerCertificate = ba.b64encode(resp.Data.ServerCertificate)
                end

                if resp.Data.ServerNonce then
                  resp.Data.ServerNonce = ba.b64encode(resp.Data.ServerNonce)
                end
              end
            elseif request.ActivateSession then
              traceI("Activating Session")
              resp.Data, resp.Error = uaClient:activateSession(request.ActivateSession.PolicyId, request.ActivateSession.Identity, request.ActivateSession.Secret)
              if resp.Data and resp.Data.ServerNonce then
                resp.Data.ServerNonce = ba.b64encode(resp.Data.ServerNonce)
              end
            elseif request.CloseSession then
              traceI("Closing Session")
              resp.Data, resp.Error = uaClient:closeSession()
            elseif request.GetEndpoints then
              traceI("Selecting endpoints: ")
              local content, error = uaClient:getEndpoints(request.GetEndpoints)
              if not error then
                -- Leave only supported secure Policies
                traceD("Filtering endpoints")
                local endpoints = {}
                for _,endpoint in ipairs(content.Endpoints) do
                  ua.Tools.printTable("Check endpoint", endpoint, traceD)
                  if not isSupportedPolicy(endpoint.SecurityPolicyUri) then
                      traceD(fmt("Unsupported endpoint: %s", endpoint.SecurityPolicyUri))
                  else
                    traceD(fmt("Supported endpoint: %s", endpoint.SecurityPolicyUri))
                    if endpoint.ServerCertificate then
                       endpoint.ServerCertificate = ba.b64encode(endpoint.ServerCertificate)
                     end

                     local userTokenPolicies = {}
                     for _,userTokenPolicy in ipairs(endpoint.UserIdentityTokens) do
                        if isSupportedTokenType(userTokenPolicy) then
                           table.insert(userTokenPolicies, userTokenPolicy)
                        end
                     end
                     endpoint.UserIdentityTokens = userTokenPolicies

                     table.insert(endpoints, endpoint)
                  end
                end
                content.Endpoints = endpoints
                traceI(fmt("Supported #%s endpoints", #endpoints))
                ua.Tools.printTable("Supported Endpoints", content, traceD)
              end
              resp.Data = content
              resp.Error = error
            elseif request.Browse then
               traceI("Browsing node: "..request.Browse.NodeId)
               resp.Data, resp.Error = uaClient:browse(tostring(request.Browse.NodeId))
            elseif request.Read then
               traceI("Reading attribute of node: "..tostring(request.Read.NodeId))
               resp.Data, resp.Error = uaClient:read(request.Read.NodeId)
            else
               resp.Error = "Unknown request type"
            end
         end
      else
         resp.Error = "JSON parse error"
      end
      local data = ba.json.encode(resp)
      traceD(fmt("Response: %s", data))
      wsSock:write(data, true)
   end

   if uaClient then
      traceI("Closing UA client")
      pcall(function()
         uaClient:disconnect()
      end)
   end

end

if request:header"Sec-WebSocket-Key" then
   traceI("New WebSocket connection")
   local s = ba.socket.req2sock(request)
   if s then
      s:event(opcUaClient,"s")
      return
   end
end

-- HTTP server
if _G.httpServer then
   _G.httpServer(request, response)
else
   response:senderror(426, "Upgrade to WebSocket")
end

?>
