FROM 10.152.183.58:5000/barracuda:v3.8.5186.84-c98742ab

COPY opcua-browser.zip /barracuda/

ENTRYPOINT [ "/barracuda/mako", "-l::/barracuda/opcua-browser.zip" ]
