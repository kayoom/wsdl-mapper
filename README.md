# WsdlMapper

[![Build Status](https://travis-ci.org/cice/wsdl-mapper.svg?branch=master)](https://travis-ci.org/cice/wsdl-mapper)
[![Dependency Status](https://gemnasium.com/badges/github.com/cice/wsdl-mapper.svg)](https://gemnasium.com/github.com/cice/wsdl-mapper)
[![Code Climate](https://codeclimate.com/github/cice/wsdl-mapper/badges/gpa.svg)](https://codeclimate.com/github/cice/wsdl-mapper)
[![Coverage Status](https://coveralls.io/repos/github/cice/wsdl-mapper/badge.svg?branch=master)](https://coveralls.io/github/cice/wsdl-mapper?branch=master)

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

* loosen the dependency on concurrent-ruby, make the async way optional.
* loosen the dependency on faraday, make the user choose which http library.
* refactor code to mitigate the naming mess. (there are so many different domain objects called name or type, which
  causes a mess in naming variables and methods. probably it makes sense to define acronyms and use them consistently
  throughout the code.)
* add more documentation, especially:
  * how-tos / tutorials / walkthroughs
  * inline documentation
  * examples
* add logging to parsing + generating

## Contributing

1. Fork it ( https://github.com/kayoom/wsdl-mapper/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
