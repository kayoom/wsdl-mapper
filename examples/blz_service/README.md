# Example BlzService

## Get WSDL

    $ curl http://www.thomas-bayer.com/axis2/services/BLZService\?wsdl >blz_service.wsdl

## Generate client

    $ wsdl-mapper generate svc blz_service.wsdl --module=BlzService --out=lib


