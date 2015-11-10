require 'test_helper'

require 'wsdl_mapper/svc_desc_parsing/parser'

module SvcDescParsingTests
  class ParserTest < Minitest::Test
    include WsdlMapper::SvcDescParsing
    include WsdlMapper::Dom

    NS = "http://example.org/schema"

    def test_messages
      desc = TestHelper.parse_wsdl 'simple_service.wsdl'

      msgs = desc.each_message.to_a
      assert_equal 3, msgs.count

      header_msg = msgs[0]
      assert_equal Name.get(NS, 'HeaderMsg'), header_msg.name
      in_msg = msgs[1]
      assert_equal Name.get(NS, 'OperationInputMsg'), in_msg.name
      out_msg = msgs[2]
      assert_equal Name.get(NS, 'OperationOutputMsg'), out_msg.name
    end

    def test_message_part_with_element
      desc = TestHelper.parse_wsdl 'simple_service.wsdl'

      msg = desc.each_message.first

      assert_equal 1, msg.parts.count
      part = msg.each_part.first

      assert_equal Name.get(NS, 'HeaderPart'), part.name
      assert_equal Name.get(NS, 'HeaderElement'), part.element_name
      refute_nil part.element
      assert_equal desc.schema.get_element(Name.get(NS, 'HeaderElement')), part.element
    end

    def test_message_part_with_type
      desc = TestHelper.parse_wsdl 'simple_service.wsdl'

      msg = desc.each_message.to_a[1]

      assert_equal 1, msg.parts.count
      part = msg.each_part.first

      assert_equal Name.get(NS, 'OperationInputPart'), part.name
      assert_equal Name.get(NS, 'OperationInputType'), part.type_name
      refute_nil part.type
      assert_equal desc.schema.get_type(Name.get(NS, 'OperationInputType')), part.type
    end

    def test_port_types
      desc = TestHelper.parse_wsdl 'simple_service.wsdl'

      port_types = desc.each_port_type.to_a
      assert_equal 1, port_types.count
      port_type = port_types.first

      assert_equal Name.get(NS, 'MyPortType'), port_type.name
    end

    def test_port_type_operations
      desc = TestHelper.parse_wsdl 'simple_service.wsdl'

      port_types = desc.each_port_type.to_a
      assert_equal 1, port_types.count
      port_type = port_types.first

      operations = port_type.each_operation.to_a
      assert_equal 1, operations.count

      operation = operations.first
      assert_equal Name.get(NS, 'SomeOperation'), operation.name

      assert_equal Name.get(NS, 'OperationInputMsg'), operation.input_message_name
      assert_equal Name.get(NS, 'OperationInputMsg'), operation.input_message.name
      assert_equal Name.get(NS, 'OperationOutputMsg'), operation.output_message_name
      assert_equal Name.get(NS, 'OperationOutputMsg'), operation.output_message.name
      assert_equal Name.get(NS, 'OperationOutputType'), operation.output_message.each_part.first.type.name
    end

    def test_services
      desc = TestHelper.parse_wsdl 'simple_service.wsdl'

      services = desc.each_service.to_a
      assert_equal 1, services.count

      service = services.first
      assert_equal Name.get(NS, 'MyService'), service.name
    end

    def test_service_ports
      desc = TestHelper.parse_wsdl 'simple_service.wsdl'

      service = desc.each_service.first
      ports = service.each_port.to_a
      assert_equal 1, ports.count
      port = ports.first

      assert_equal Name.get(NS, "MyPort"), port.name
      assert_equal Name.get(NS, "MyBinding"), port.binding_name
      assert_equal "http://example.org/api", port.address_location
      assert_equal Name.get(NS, 'MyBinding'), port.binding.name
    end

    def test_bindings
      desc = TestHelper.parse_wsdl 'simple_service.wsdl'

      bindings = desc.each_binding.to_a
      assert_equal 1, bindings.count
      binding = bindings.first

      assert_equal Name.get(NS, 'MyBinding'), binding.name
      assert_equal Name.get(NS, 'MyPortType'), binding.type_name
      assert_equal "document", binding.style
      assert_equal SoapHttp::NS, binding.transport
      assert_equal Name.get(NS, 'MyPortType'), binding.type.name
    end

    def test_binding_operations
      desc = TestHelper.parse_wsdl 'simple_service.wsdl'

      bindings = desc.each_binding.to_a
      binding = bindings.first

      operations = binding.each_operation.to_a
      assert_equal 1, operations.count
      operation = operations.first

      assert_equal Name.get(NS, 'SomeOperation'), operation.name
      assert_equal "MySoapAction", operation.soap_action

      input = operation.input
      assert_equal Name.get(NS, 'HeaderMsg'), input.header.message_name
      assert_equal Name.get(NS, 'HeaderMsg'), input.header.message.name
      assert_equal Name.get(NS, 'HeaderPart'), input.header.part_name
      assert_equal Name.get(NS, 'HeaderPart'), input.header.part.name
      assert_equal false, input.header.encoded?
      assert_equal false, input.body.encoded?

      output = operation.output
      assert_equal Name.get(NS, 'HeaderMsg'), output.header.message_name
      assert_equal Name.get(NS, 'HeaderMsg'), output.header.message.name
      assert_equal Name.get(NS, 'HeaderPart'), output.header.part_name
      assert_equal Name.get(NS, 'HeaderPart'), output.header.part.name
      assert_equal Name.get(NS, 'HeaderElement'), output.header.part.element.name
      assert_equal false, output.body.encoded?
    end

    def test_embedded_schema
      desc = TestHelper.parse_wsdl 'simple_service.wsdl'
      schema = desc.schema

      assert_equal 3, schema.each_type.count
      assert_equal 1, schema.each_element.count
    end
  end
end
