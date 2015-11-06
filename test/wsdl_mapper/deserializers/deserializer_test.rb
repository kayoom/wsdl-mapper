require 'test_helper'

require 'wsdl_mapper/dom/name'
require 'wsdl_mapper/deserializers/deserializer'
require 'wsdl_mapper/core_ext/time_duration'

module DeserializersTests
  class DeserializerTest < ::Minitest::Test
    include WsdlMapper::CoreExt
    include WsdlMapper::Dom
    include WsdlMapper::Deserializers

    class NoteType
      attr_accessor :to, :date_time, :uuid
    end

    NoteTypeDeserializer = Deserializer::Mapping.new NoteType do
      register_attr :uuid, WsdlMapper::Dom::Name.new(nil, 'uuid'), WsdlMapper::Dom::Name.new(WsdlMapper::Dom::BuiltinType::NAMESPACE, 'token')
      register_prop :to, WsdlMapper::Dom::Name.new(nil, 'to'), WsdlMapper::Dom::Name.new(WsdlMapper::Dom::BuiltinType::NAMESPACE, 'string')
      register_prop :date_time, WsdlMapper::Dom::Name.new(nil, 'dateTime'), WsdlMapper::Dom::Name.new(WsdlMapper::Dom::BuiltinType::NAMESPACE, 'dateTime')
    end

    def test_simple_example
      xml = <<XML
<?xml version="1.0" encoding="UTF-8"?>
<noteType uuid="ABCD-1234">
  <to>to@example.org</to>
  <dateTime>2002-05-30T09:30:10-06:00</dateTime>
</noteType>
XML

      deserializer = Deserializer.new
      deserializer.register Name.new(nil, "noteType"), NoteTypeDeserializer

      obj = deserializer.from_xml xml
      assert_kind_of NoteType, obj
      assert_equal "ABCD-1234", obj.uuid
      assert_equal "to@example.org", obj.to
      assert_equal ::DateTime.new(2002, 5, 30, 9, 30, 10, '-6'), obj.date_time
    end
  end
end
