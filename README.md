# OPC-UA Client and Web Client

This example includes an OPC-UA browser user interface and a server
side OPC-UA client. The OPC-UA browser user interface is implemented
as an HTML and JavaScript powered Single Page Application (SPA). The
SPA runs in the browser and communicates with the server side OPC-UA
client using WebSockets.

![OPC-UA Web Client Block Diagram](https://realtimelogic.com/products/opc-ua/opc-ua-web-client.png)

The HTML user interface enables you to connect to any OPC UA server
via the OPC-UA client running on the server side. The two
applications (the OPC-UA client and the OPC-UA server found in the
[../servers/server](../servers/server) directory) are automatically
loaded when you start the Mako Server in this directory. The server
example lets you quickly test the OPC UA client without having to
start any third party OPC UA server.


The client's default OPC-UA endpoint address is to the local OPC-UA server. You
can use any OPC-UA server address, such as the following public OPC-UA
server: opc.tcp://opcuaserver.com:48010. You can also connect other
(external) OPC-UA clients to the server example. See the
[OPC-UA Client to Server Tutorial](https://realtimelogic.com/ba/opcua/thirdparty_clients.html)
in the OPC-UA main documentation for how to connect various OPC-UA
clients.

## Run the example as follows:

1. Open a command window in this directory
2. Start the Mako Server without providing any arguments; the Mako Server will load both the client example and the server example. See the provided mako.conf for details. The mako.conf file also shows how the Mako server configuration file can be used for setting custom OPC-UA settings.
3. Open a browser window and navigate to http://localhost:portno, where portno is the port number the Mako Server is listening on.
4. Click the "Connect to endpoint" button to connect to the OPC-UA Server loaded by the Mako Server
5. Click the plus (+) symbol in the browser to expand the root node.

The following slideshow shows how to connect to an OPC-UA server and how to browse the OPC-UA server nodes:

![OPC-UA Web Client Slides](https://realtimelogic.com/products/opc-ua/web-client-slides.gif)
