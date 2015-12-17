require 'test_helper'

require 'wsdl_mapper/runtime/simple_http_backend'

module RuntimeTests
  class SimpleHttpBackendTest < WsdlMapperTesting::Test
    def setup
      @operation = Minitest::Mock.new

      @cnx = WsdlMapperTesting::StubConnection.new
      @test_url = 'http://example.org/some-url'
      @test_action = 'SomeAction'
      @input = Object.new
      @output = Object.new
      @input_s8r = Minitest::Mock.new
      @output_d10r = Minitest::Mock.new
      @message = WsdlMapper::Runtime::Message.new @test_url, @test_action, @input
      @backend = WsdlMapper::Runtime::SimpleHttpBackend.new(connection: @cnx)
    end

    def verify_mocks
      @operation.verify
      @input_s8r.verify
      @output_d10r.verify
    end

    focus
    def test_a_successful_request
      @cnx.stub_request @test_url, 'foo bar', 'lorem ipsum'

      @input_s8r.expect :to_xml, 'foo bar', args=[@input]
      @output_d10r.expect :from_xml, @output, args=['lorem ipsum']
      @operation.expect :new_input, @message, args=[{ body: @input }]
      @operation.expect :input_s8r, @input_s8r
      @operation.expect :output_d10r, @output_d10r

      response = @backend.dispatch @operation, @input

      assert_kind_of WsdlMapper::Runtime::Response, response
      assert_equal @output, response.envelope
      verify_mocks
    end
  end
end
