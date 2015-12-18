require 'test_helper'
require 'wsdl_mapper_testing/stub_connection'

require 'wsdl_mapper/runtime/request'
require 'wsdl_mapper/runtime/middlewares/simple_dispatcher'

module RuntimeTests
  module MiddlewareTests
    class SimpleDispatcherTest < Minitest::Test
      def setup
        @cnx = WsdlMapperTesting::StubConnection.new
        @dispatcher = WsdlMapper::Runtime::Middlewares::SimpleDispatcher.new @cnx
      end

      def fake_request(url, body)
        request = WsdlMapper::Runtime::Request.new(nil)
        request.xml = body
        request.url = URI url
        request
      end

      def test_successful_request
        request = fake_request '/some-url', 'foo bar'
        @cnx.stub_request '/some-url', 'foo bar', 'lorem ipsum'

        op, response = @dispatcher.call nil, request

        assert_equal 200, response.status
        assert_equal 'lorem ipsum', response.body
      end

      def test_error_on_request
        request = fake_request '/some-url', 'foo bar'
        @cnx.stub_error '/some-url', Faraday::Error.new('connection failed')

        begin
          @dispatcher.call nil, request
          assert false
        rescue => e
          assert_kind_of WsdlMapper::Runtime::Errors::TransportError, e
        end
      end
    end
  end
end
