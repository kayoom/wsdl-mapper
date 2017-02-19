# Example Calculator

## Get WSDL

    $ curl http://www.dneonline.com/calculator.asmx\?WSDL >calculator.wsdl

## Generate client

    $ wsdl-mapper generate svc calculator.wsdl --module=Calculator --out=lib


