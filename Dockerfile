FROM 10.152.183.58:5000/barracuda:v3.8.5186.77

COPY opcua-client.zip /barracuda/

ENTRYPOINT [ "/barracuda/mako", "-l::/barracuda/opcua-client.zip" ]
