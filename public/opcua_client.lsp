<?lsp

local ua = require("opcua.api")

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

   if type == ua.Types.UserTokenType.Anonymous then
      return true
   elseif type == ua.Types.UserTokenType.Certificate then
      return policyUri == nil or isSupportedPolicy(policyUri)
   elseif type == ua.Types.UserTokenType.UserName then
      return policyUri == nil or isSupportedPolicy(policyUri)
   end

   return false
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
            tracep(false, 4, "Received Connect request")
            local endpointUrl = request.ConnectEndpoint.EndpointUrl
            if endpointUrl then
               if uaClient then
                  tracep(false, 4, "Closing UA client")
                  pcall(function()
                     uaClient:closeSession()
                     uaClient:disconnect()
                  end)
               end
               tracep(false, 4, "Creating new UA client")
               clientConfig.cosocketMode = true
               ua.Tools.printTable("Client configuration", clientConfig, ua.trace.dbg)
               -- Cosocket mode will automatically be enabled since are we in cosocket context
               uaClient = ua.newClient(clientConfig)
               tracep(false, 4, "Connecting to endpoint '".. endpointUrl .. "' transportProfileUri: '" .. (request.ConnectEndpoint.TransportProfileUri or "") .. "'")
               local result = uaClient:connect(endpointUrl, request.ConnectEndpoint.TransportProfileUri)
               if result then
                  uaClient = nil
                  trace("Connection failed: ", result)
                  resp.Error = result
               else
                  tracep(false, 5, "Connected")
               end
            else
               tracep(false, 1, "Error: client sent empty endpoint URL")
               resp.Error = "Empty endpointURL"
            end
         else
            if not uaClient then
               tracep(false, 1, "Error: OPCUA request without calling connectEndpoint")
               resp.Error = "OPC UA Client not connected"
            elseif request.OpenSecureChannel then
              local timeoutMs = request.OpenSecureChannel.TimeoutMs or 3600000
              local securityPolicyUri = request.OpenSecureChannel.SecurityPolicyUri or ua.Types.SecurityPolicy.None
              local securityMode = request.OpenSecureChannel.SecurityMode or ua.Types.MessageSecurityMode.None
              local serverCertificate = request.OpenSecureChannel.ServerCertificate
              if serverCertificate == ba.json.null then
               serverCertificate = nil
              elseif serverCertificate then
                serverCertificate = ba.b64decode(serverCertificate)
              end
              tracep(false, 4, "Opening secureChannel")
              resp.Data, resp.Error = uaClient:openSecureChannel(timeoutMs, securityPolicyUri, securityMode, serverCertificate)
              if resp.Data then
                 if resp.Data.ServerNonce then
                   resp.Data.ServerNonce = ba.b64encode(resp.Data.ServerNonce)
                 end
              end
            elseif request.CloseSecureChannel then
              tracep(false, 4, "Closing Secure Channel")
              resp.Error = uaClient:closeSecureChannel()
            elseif request.CreateSession then
              tracep(false, 4, "Creating Session")
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
              tracep(false, 4, "Activating Session")
              resp.Data, resp.Error = uaClient:activateSession(request.ActivateSession.PolicyId, request.ActivateSession.Identity, request.ActivateSession.Secret)
              if resp.Data and resp.Data.ServerNonce then
                resp.Data.ServerNonce = ba.b64encode(resp.Data.ServerNonce)
              end
            elseif request.CloseSession then
              tracep(false, 4, "Closing Session")
              resp.Data, resp.Error = uaClient:closeSession()
            elseif request.GetEndpoints then
              tracep(false, 4, "Selecting endpoints: ")
              local content, error = uaClient:getEndpoints(request.GetEndpoints)
              if not error then
                -- Leave only supported secure Policies
                local endpoints = {}
                for _,endpoint in ipairs(content.Endpoints) do
                  if isSupportedPolicy(endpoint.SecurityPolicyUri) then
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
              end
              resp.Data = content
              resp.Error = error
            elseif request.Browse then
               tracep(false, 4, "Browsing node: "..request.Browse.NodeId)
               resp.Data, resp.Error = uaClient:browse(tostring(request.Browse.NodeId))
            elseif request.Read then
               tracep(false, 4, "Reading attribute of node: "..tostring(request.Read.NodeId))
               resp.Data, resp.Error = uaClient:read(request.Read.NodeId)
            else
               resp.Error = "Unknown request type"
               tracep(false, 1, resp.Error)
            end
         end
      else
         resp.Error = "JSON parse error"
         tracep(false, 1, resp.Error)
      end
      local data = ba.json.encode(resp)
      wsSock:write(data, true)
   end

   if uaClient then
      tracep(false, 4, "Closing UA client")
      pcall(function()
         uaClient:disconnect()
      end)
   end

end

if request:header"Sec-WebSocket-Key" then
   tracep(false, 4, "New WebSocket connection")
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
