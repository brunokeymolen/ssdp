# ssdp
linux command line SSDP (DLNA/UPnP) search tool.


This is a stand alone SSDP (Simple Service Discovery Protocol) utiliy for linux bash,
extracted from the upnpx project at : https://github.com/fkuehne/upnpx



## Build & install: 

* make
* sudo make install


## example:
```
ssdp-search -t 5 | grep ACT-Denon
035. usn=uuid:<obfuscated>::urn:schemas-denon-com:device:ACT-Denon:1, type=ACT-Denon, version=1, location=http://<obfuscated>/upnp/desc/aios_device/aios_device.xml
```


2020, Bruno Keymolen, bruno.keymolen@gmail.com
