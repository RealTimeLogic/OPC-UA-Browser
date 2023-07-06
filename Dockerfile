FROM 10.152.183.58:5000/barracuda:v3.8.5186.82

COPY opcua-browser.zip /barracuda/

ENTRYPOINT [ "/barracuda/mako", "-l::/barracuda/opcua-browser.zip" ]
