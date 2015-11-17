require 'test_helper'

require 'wsdl_mapper/dom/name'
require 'wsdl_mapper/deserializers/lazy_loading_deserializer'
require 'wsdl_mapper/core_ext/time_duration'

module DeserializersTests
  class DeserializerIntegrationTest < ::Minitest::Test
    include WsdlMapper::CoreExt
    include WsdlMapper::Dom
    include WsdlMapper::Deserializers

    TestModule = <<RUBY
require "wsdl_mapper/deserializers/type_directory"
require "wsdl_mapper/deserializers/element_directory"
class NoteType
  attr_accessor :to, :from, :heading, :body
end
TypeDirectory = ::WsdlMapper::Deserializers::TypeDirectory.new
NoteTypeDeserializer = TypeDirectory.register_type([nil, 'noteType'], NoteType) do
  register_prop :to, [nil, 'to'], ['http://www.w3.org/2001/XMLSchema', 'string']
  register_prop :from, [nil, 'from'], ['http://www.w3.org/2001/XMLSchema', 'string']
  register_prop :heading, [nil, 'heading'], ['http://www.w3.org/2001/XMLSchema', 'string']
  register_prop :body, [nil, 'body'], ['http://www.w3.org/2001/XMLSchema', 'string']
end
ElementDirectory = ::WsdlMapper::Deserializers::ElementDirectory.new(TypeDirectory) do
  register_element [nil, 'note'], [nil, 'noteType'], 'note_type_deserializer', '::NoteTypeDeserializer'
end
RUBY

    def test_integration
      test_module_name = 'TestModule' + SecureRandom.hex
      eval "module #{test_module_name}\n#{TestModule}\nend"
      test_module = self.class.const_get test_module_name

      xml = <<XML
<?xml version="1.0" encoding="UTF-8"?>
<note>
  <to>to@example.org</to>
  <from>from@example.org</from>
  <heading>This is the subject</heading>
  <body>This is the body</body>
</note>
XML

      deserializer = LazyLoadingDeserializer.new test_module.const_get('ElementDirectory')
      obj = deserializer.from_xml xml

      assert_kind_of test_module.const_get(:NoteType), obj
      assert_equal 'to@example.org', obj.to
      assert_equal 'This is the body', obj.body
    end
  end
end
