# WsdlMapper

WsdlMapper is a ruby gem to communicate with [SOAP](https://en.wikipedia.org/wiki/SOAP) services.
It provides:

1. A generator to create classes from `XSD` schema files.
2. (De)Serializers to parse and write `XML` files to/from instances of these classes.
3. A generator to create SOAP clients from `WSDL` files.

Currently it supports **only** WSDL 1.1, but with Document or RPC message style and literal or encoded style.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'wsdl-mapper'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wsdl-mapper

## Usage

### XSD

    $ wsdl-mapper generate all some-schema.xsd --out some-schema --module SomeSchema
    
Will generate models and (de)serializers for the given `XSD` schema. The generated classes are all nested within the
specified module `SomeSchema` and are put under `${pwd}/some-schema` (`pwd` == current working directory).

For all available options, see
    
    $ wsdl-mapper help generate
    
### SOAP / WSDL

    $ wsdl-mapper generate svc some-svc.wsdl --out some-schema --module SomeSchema
    
Will generate models, (de)serializers and a client for the given `WSDL` service.
    
## TODOs


## Contributing

1. Fork it ( https://github.com/kayoom/wsdl-mapper/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
