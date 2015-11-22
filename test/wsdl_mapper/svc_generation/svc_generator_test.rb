require 'test_helper'

require 'wsdl_mapper/svc_generation/svc_generator'

module SvcDescParsingTests
  class SvcGeneratorTest < GenerationTest
    include WsdlMapper::SvcGeneration
    include WsdlMapper::Dom

    NS = 'http://example.org/schema'

    def generate name
      @desc = TestHelper.parse_wsdl name
      generator = SvcGenerator.new context
      generator.generate @desc
    end

    def test_api_generation
      generate 'simple_service.wsdl'

      assert_file_is 'api.rb', <<RUBY
require "wsdl_mapper/runtime/api"

require "my_service"

class Api < ::WsdlMapper::Runtime::Api
  attr_reader :my_service

  def initialize(options = {})
    super(options)
    @my_service = ::MyService.new(self)
  end
end
RUBY
    end

    def test_service_generation
      generate 'simple_service.wsdl'

      assert_file_is 'my_service.rb', <<RUBY
require "wsdl_mapper/runtime/service"

class MyService < ::WsdlMapper::Runtime::Service
  require "my_service/my_port"

  attr_reader :my_port

  def initialize(api)
    super(api)
    @my_port = ::MyService::MyPort.new(api, self)
  end
end
RUBY
    end

    def test_port_generation
      generate 'simple_service.wsdl'

      assert_file_is 'my_service/my_port.rb', <<RUBY
require "wsdl_mapper/runtime/port"

class MyService
  class MyPort < ::WsdlMapper::Runtime::Port
    require "my_service/my_port/some_operation_factory"

    SOAP_ADDRESS = "http://example.org/api"

    def initialize(api, service)
      super(api, service)
      @some_operation = ::MyService::MyPort::SomeOperationFactory.new(api, service, self)
    end
  end
end
RUBY
    end

    def test_operation_generation
      generate 'simple_service.wsdl'

      assert_file_is 'my_service/my_port/some_operation_factory.rb', <<RUBY
require "wsdl_mapper/runtime/operation_factory"

class MyService
  class MyPort
    class SomeOperationFactory < ::WsdlMapper::Runtime::OperationFactory
      SOAP_ACTION = "MySoapAction"

      def initialize(api, service, port)
        super(api, service, port)
      end
    end
  end
end
RUBY
    end
  end
end
