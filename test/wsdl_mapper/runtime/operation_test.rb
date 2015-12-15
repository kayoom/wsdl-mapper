require 'test_helper'

require 'wsdl_mapper/runtime/operation'

module RuntimeTests
  class OperationTest < WsdlMapperTesting::Test
    class TestOperation < WsdlMapper::Runtime::Operation
      attr_reader :requires, :loaded_requires, :loaded
      attr_accessor :port, :soap_action

      def initialize
        super(nil, nil, nil)
        @loaded_requires = []
      end

      def require(path)
        @loaded_requires << path
      end
    end

    def test_requiring
      op = TestOperation.new
      op.requires << 'some_module'

      op.load_requires

      assert op.loaded
      assert_equal ['some_module'], op.loaded_requires
    end

    def test_requiring_twice
      op = TestOperation.new
      op.requires << 'some_module'

      op.load_requires
      op.load_requires

      assert_equal ['some_module'], op.loaded_requires
    end

    def test_loading_on_use
      methods = %w[new_input new_output input_s8r output_s8r input_d10r output_d10r]

      methods.each do |method|
        op = TestOperation.new
        op.send method
        assert op.loaded
      end
    end

    def test_envelope_creation
      op = TestOperation.new
      header = Object.new
      body = Object.new

      envelope = op.new_envelope header, body

      assert_kind_of WsdlMapper::SvcDesc::Envelope, envelope
      assert_equal header, envelope.header
      assert_equal body, envelope.body
    end

    def test_message_creation
      op = TestOperation.new
      op.soap_action = 'SomeAction'
      op.port = Minitest::Mock.new.expect(:_soap_address, '/some-url')
      header = Object.new
      body = Object.new

      message = op.new_message header, body

      assert_kind_of WsdlMapper::Runtime::Message, message
      assert_equal 'SomeAction', message.action
      assert_equal '/some-url', message.address
      assert_equal header, message.envelope.header
      assert_equal body, message.envelope.body
    end
  end
end
