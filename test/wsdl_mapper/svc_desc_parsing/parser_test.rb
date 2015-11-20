require 'test_helper'

require 'wsdl_mapper/svc_desc_parsing/parser'

module SvcDescParsingTests
  class ParserTest < WsdlMapperTesting::Test
    include WsdlMapper::SvcDescParsing
    include WsdlMapper::Dom

    NS = 'http://example.org/schema'

    def test_name
      desc = TestHelper.parse_wsdl 'simple_service.wsdl'

      assert_equal 'MyWsdl', desc.name
    end

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
      assert_equal desc.get_element(Name.get(NS, 'HeaderElement')), part.element
    end

    def test_message_part_with_type
      desc = TestHelper.parse_wsdl 'simple_service.wsdl'

      msg = desc.each_message.to_a[1]

      assert_equal 1, msg.parts.count
      part = msg.each_part.first

      assert_equal Name.get(NS, 'OperationInputPart'), part.name
      assert_equal Name.get(NS, 'OperationInputType'), part.type_name
      refute_nil part.type
      assert_equal desc.get_type(Name.get(NS, 'OperationInputType')), part.type
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

      assert_equal Name.get(NS, 'OperationInputMsg'), operation.input.message_name
      assert_equal Name.get(NS, 'OperationInputMsg'), operation.input.message.name

      assert_equal Name.get(NS, 'OperationOutputMsg'), operation.output.message_name
      assert_equal Name.get(NS, 'OperationOutputMsg'), operation.output.message.name
      assert_equal Name.get(NS, 'OperationOutputType'), operation.output.message.each_part.first.type.name

      assert_equal Name.get(NS, 'StandardFault'), operation.each_fault.first.name
      assert_equal Name.get(NS, 'OperationOutputMsg'), operation.each_fault.first.message_name
      assert_equal Name.get(NS, 'OperationOutputMsg'), operation.each_fault.first.message.name
    end

    def test_port_type_operation_overloads
      desc = TestHelper.parse_wsdl 'simple_service_with_overload.wsdl'

      port_types = desc.each_port_type.to_a
      assert_equal 1, port_types.count
      port_type = port_types.first

      operations = port_type.each_operation.to_a
      assert_equal 2, operations.count

      operation = operations.last
      assert_equal Name.get(NS, 'SomeOperation'), operation.name

      assert_equal Name.get(NS, 'OperationInputMsg2'), operation.input.message.name

      bindings = desc.each_binding.to_a
      binding = bindings.first
      operations = binding.each_operation.to_a

      assert_equal 2, operations.count
      binding_operation = operations.last

      assert_equal operation, binding_operation.target
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

      assert_equal Name.get(NS, 'MyPort'), port.name
      assert_equal Name.get(NS, 'MyBinding'), port.binding_name
      assert_equal 'http://example.org/api', port.address_location
      assert_equal Name.get(NS, 'MyBinding'), port.binding.name
    end

    def test_bindings_document
      desc = TestHelper.parse_wsdl 'simple_service.wsdl'

      bindings = desc.each_binding.to_a
      assert_equal 2, bindings.count
      binding = bindings.first

      assert_equal Name.get(NS, 'MyBinding'), binding.name
      assert_equal Name.get(NS, 'MyPortType'), binding.type_name
      assert_equal 'document', binding.style
      assert_equal SoapHttp::NS, binding.transport
      assert_equal Name.get(NS, 'MyPortType'), binding.type.name
    end

    def test_binding_document_operations
      desc = TestHelper.parse_wsdl 'simple_service.wsdl'

      bindings = desc.each_binding.to_a
      binding = bindings.first

      operations = binding.each_operation.to_a
      assert_equal 1, operations.count
      operation = operations.first

      assert_equal Name.get(NS, 'SomeOperation'), operation.name
      assert_equal 'MySoapAction', operation.soap_action

      input = operation.input
      refute_nil input.target
      assert_equal Name.get(NS, 'HeaderMsg'), input.each_header.first.message_name
      assert_equal Name.get(NS, 'HeaderMsg'), input.each_header.first.message.name
      assert_equal Name.get(NS, 'HeaderPart'), input.each_header.first.part_name
      assert_equal Name.get(NS, 'HeaderPart'), input.each_header.first.part.name
      assert_equal false, input.each_header.first.encoded?
      assert_equal false, input.body.encoded?

      output = operation.output
      refute_nil output.target
      assert_equal Name.get(NS, 'HeaderMsg'), output.each_header.first.message_name
      assert_equal Name.get(NS, 'HeaderMsg'), output.each_header.first.message.name
      assert_equal Name.get(NS, 'HeaderPart'), output.each_header.first.part_name
      assert_equal Name.get(NS, 'HeaderPart'), output.each_header.first.part.name
      assert_equal Name.get(NS, 'HeaderElement'), output.each_header.first.part.element.name
      assert_equal false, output.body.encoded?

      fault = operation.each_fault.first
      refute_nil fault.target
      assert_equal Name.get(NS, 'StandardFault'), fault.name
      assert_equal Name.get(NS, 'StandardFault'), fault.soap_fault.name
      assert_equal false, fault.soap_fault.encoded?
      assert_equal Name.get(NS, 'StandardFault'), fault.target.name

      header_fault = input.each_header.first.each_header_fault.first
      refute_nil header_fault
      assert_equal Name.get(NS, 'OperationInputMsg'), header_fault.message_name
      assert_equal Name.get(NS, 'OperationInputPart'), header_fault.part_name
      assert_equal Name.get(NS, 'OperationInputMsg'), header_fault.message.name
      assert_equal Name.get(NS, 'OperationInputPart'), header_fault.part.name
      assert_equal false, header_fault.encoded?
    end

    def test_bindings_rpc
      desc = TestHelper.parse_wsdl 'simple_service.wsdl'

      bindings = desc.each_binding.to_a
      assert_equal 2, bindings.count
      binding = bindings.last

      assert_equal Name.get(NS, 'MyBindingRPC'), binding.name
      assert_equal Name.get(NS, 'MyPortType'), binding.type_name
      assert_equal 'rpc', binding.style
      assert_equal SoapHttp::NS, binding.transport
      assert_equal Name.get(NS, 'MyPortType'), binding.type.name
    end

    def test_binding_rpc_operations
      desc = TestHelper.parse_wsdl 'simple_service.wsdl'

      bindings = desc.each_binding.to_a
      binding = bindings.last

      operations = binding.each_operation.to_a
      assert_equal 1, operations.count
      operation = operations.first

      assert_equal Name.get(NS, 'SomeOperation'), operation.name
      assert_equal 'MySoapAction', operation.soap_action
      assert_equal desc.each_port_type.first.each_operation.first, operation.target

      input = operation.input
      assert_equal Name.get(NS, 'OperationInputMsg'), input.message.name
      assert_equal Name.get(NS, 'HeaderMsg'), input.each_header.first.message_name
      assert_equal Name.get(NS, 'HeaderMsg'), input.each_header.first.message.name
      assert_equal Name.get(NS, 'HeaderPart'), input.each_header.first.part_name
      assert_equal Name.get(NS, 'HeaderPart'), input.each_header.first.part.name
      assert_equal true, input.each_header.first.encoded?
      assert_equal true, input.body.encoded?
      assert_equal 'http://schemas.xmlsoap.org/soap/encoding/', input.body.encoding_styles.first
      assert_equal 'http://example.org/schema', input.body.namespace
      assert_equal [Name.get(NS, 'OperationInputPart')], input.body.part_names
      assert_equal Name.get(NS, 'OperationInputPart'), input.body.parts.first.name

      output = operation.output
      assert_equal Name.get(NS, 'OperationOutputMsg'), output.message.name
      assert_equal Name.get(NS, 'HeaderMsg'), output.each_header.first.message_name
      assert_equal Name.get(NS, 'HeaderMsg'), output.each_header.first.message.name
      assert_equal Name.get(NS, 'HeaderPart'), output.each_header.first.part_name
      assert_equal Name.get(NS, 'HeaderPart'), output.each_header.first.part.name
      assert_equal Name.get(NS, 'HeaderElement'), output.each_header.first.part.element.name
      assert_equal true, output.each_header.first.encoded?
      assert_equal true, output.body.encoded?
      assert_equal 'http://schemas.xmlsoap.org/soap/encoding/', output.body.encoding_styles.first
      assert_equal 'http://example.org/schema', output.body.namespace
      assert_equal [Name.get(NS, 'OperationOutputPart')], output.body.part_names
      assert_equal Name.get(NS, 'OperationOutputPart'), output.body.parts.first.name
    end

    def test_embedded_schema
      desc = TestHelper.parse_wsdl 'simple_service.wsdl'
      schema = desc.each_schema.first

      assert_equal 3, schema.each_type.count
      assert_equal 1, schema.each_element.count
    end
  end
end
