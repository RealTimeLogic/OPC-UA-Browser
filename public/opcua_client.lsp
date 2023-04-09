<?lsp

local ua = require("opcua.api")

local function isSupportedPolicy(policyUri)
   for _,policy in ipairs(clientConfig.securePolicies) do
     if policy.securityPolicyUri == policyUri then
       return true
      end
   end
end

local function opcUaClient(wsSock)
   local ok,uaClient
   while true do
      local data,err = wsSock:read()
      if not data then
         trace("WS close:",err)
         break
      end

      local request = ba.json.decode(data)
      if not request.id then
         trace("ERROR: Request has no 'id': ", data)
         break
      end

      local resp = { id = request and request.id }
      if request then
         if request.connectEndpoint then
            trace("Received Connect request")
            local endpointUrl = request.connectEndpoint.endpointUrl
            if endpointUrl then
               if uaClient then
                  trace"Closing UA client"
                  pcall(function()
                     uaClient:closeSession()
                     uaClient:disconnect()
                  end)
               end
               trace"Creating new UA client"
               clientConfig.cosocketMode = true
               ua.Tools.printTable("Client configuration", clientConfig)
               -- Cosocket mode will automatically be enabled since are we in cosocket context
               uaClient = ua.newClient(clientConfig)
               trace("Connecting to endpoint '".. endpointUrl .. "'")
               local result = uaClient:connect(endpointUrl)
               if result then
                  uaClient = nil
                  trace("Connection failed: ", result)
                  resp.error = result
               else
                  trace("Connected")
               end
            else
               trace("Error: client sent empty endpoint URL")
               resp.error = "Empty endpointURL"
            end
         else
            if not uaClient then
               trace("Error: OPCUA request without calling connectEndpoint")
               resp.error = "OPC UA Client not connected"
            elseif request.openSecureChannel then
              local timeoutMs = request.openSecureChannel.timeoutMs or 3600000
              local securityPolicyUri = request.openSecureChannel.securityPolicyUri or ua.Types.SecurityPolicy.None
              local securityMode = request.openSecureChannel.securityMode or ua.Types.MessageSecurityMode.None
              local serverCertificate = request.openSecureChannel.serverCertificate
              if serverCertificate == ba.json.null then
               serverCertificate = nil
              elseif serverCertificate then
                serverCertificate = ba.b64decode(serverCertificate)
              end
              trace("Opening secureChannel")
              resp.data, resp.error = uaClient:openSecureChannel(timeoutMs, securityPolicyUri, securityMode, serverCertificate)
              if resp.data then
                 if resp.data.serverNonce then
                   resp.data.serverNonce = ba.b64decode(resp.data.serverNonce)
                 end
              end
            elseif request.closeSecureChannel then
              trace("Closing Secure Channel")
              resp.error = uaClient:closeSecureChannel()
            elseif request.createSession then
              trace("Creating Session")
              local sessionName = request.createSession.sessionName
              local sessionTimeout = request.createSession.sessionTimeout
              ua.debug()
              resp.data, resp.error = uaClient:createSession(sessionName, sessionTimeout)
              if not resp.error then
                for _, endpoint in ipairs(resp.data.serverEndpoints) do
                  if endpoint.serverCertificate then
                    endpoint.serverCertificate = ba.b64encode(endpoint.serverCertificate)
                  end
                end
                if resp.data.serverSignature.signature then
                  resp.data.serverSignature.signature = ba.b64encode(resp.data.serverSignature.signature)
                end

                if resp.data.serverCertificate then
                  resp.data.serverCertificate = ba.b64encode(resp.data.serverCertificate)
                end

                if resp.data.serverNonce then
                  resp.data.serverNonce = ba.b64encode(resp.data.serverNonce)
                end

              end
            elseif request.activateSession then
              trace("Activating Session")
              resp.data, resp.error = uaClient:activateSession(request.activateSession.policyId, request.activateSession.identity, request.activateSession.secret)
              if resp.data and resp.data.serverNonce then
                resp.data.serverNonce = ba.b64encode(resp.data.serverNonce)
              end
            elseif request.closeSession then
              trace("Closing Session")
              resp.data, resp.error = uaClient:closeSession()
            elseif request.getEndpoints then
              trace("Selecting endpoints: ")
              local content, error = uaClient:getEndpoints(request.getEndpoints)
              if not error then
                -- Leave only supported secure Policies
                local endpoints = {}
                for _,endpoint in ipairs(content.endpoints) do
                  if isSupportedPolicy(endpoint.securityPolicyUri) then
                     if endpoint.serverCertificate then
                       endpoint.serverCertificate = ba.b64encode(endpoint.serverCertificate)
                     end
                     table.insert(endpoints, endpoint)
                  end
                end
                content.endpoints = endpoints
              end
              resp.data = content
              resp.error = error
            elseif request.browse then
               trace("Browsing node: "..request.browse.nodeId)
               resp.data, resp.error = uaClient:browse(request.browse.nodeId)
            elseif request.read then
               trace("Reading attribute of node: "..request.read.nodeId)
               resp.data, resp.error = uaClient:read(request.read.nodeId)
            else
               resp.error = "Unknown request type"
            end
         end
      else
         resp.error = "JSON parse error"
      end
      local data = ba.json.encode(resp)
      wsSock:write(data, true)
   end

   if uaClient then
      trace"Closing UA client"
      pcall(function()
         uaClient:closeSession()
         uaClient:disconnect()
      end)
   end

end

if request:header"Sec-WebSocket-Key" then
   trace"New WebSocket connection"
   local s = ba.socket.req2sock(request)
   if s then
      s:event(opcUaClient,"s")
      return
   end
end
response:senderror(404)
?>
