# EvrmoreElectrumx

dockerized deployment of evrmored and electrumx

clone these into ./workspace/
- https://github.com/EvrmoreOrg/Evrmore
- https://github.com/moontreeapp/electrumx-evrmore

### run

docker run -d --net=host -p 8819:8819 -p 8820:8820 -p 50001:50001 -p 50002:50002 -v D:\Divya\Backend\EvrmoreElectrumx\databases\electrumx:/db -v D:\Divya\Backend\EvrmoreElectrumx\databases\evrmore:/var/lib/evrmore -v D:\Divya\Backend\EvrmoreElectrumx\databases\electrumx\ssl_cert:/home/myid/electrumx-evrmore/ssl_cert -e DAEMON_URL="http://youruser:yourpass@localhost:8766" -e REPORT_SERVICES=tcp://example.com:50001 electrumx

docker run -it -p 8819:8819 -p 8820:8820 -p 50001:50001 -p 50002:50002 -v c:\repos\Satori\EvrmoreElectrumx\databases\electrumx:/db -v c:\repos\Satori\EvrmoreElectrumx\databases\evrmore:/var/lib/evrmore -e DAEMON_URL="http://youruser:yourpass@localhost:8766" -e REPORT_SERVICES=tcp://example.com:50001 evrelectrumx:test bash
