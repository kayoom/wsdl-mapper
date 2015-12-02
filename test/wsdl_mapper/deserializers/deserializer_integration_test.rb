require 'test_helper'

require 'wsdl_mapper/dom/name'
require 'wsdl_mapper/deserializers/lazy_loading_deserializer'
require 'wsdl_mapper/core_ext/time_duration'

module DeserializersTests
  class DeserializerIntegrationTest < ::WsdlMapperTesting::Test
    include WsdlMapper::CoreExt
    include WsdlMapper::Dom
    include WsdlMapper::Deserializers

    TestModule1 = <<RUBY
require "wsdl_mapper/deserializers/type_directory"
require "wsdl_mapper/deserializers/element_directory"
class NoteType
  attr_accessor :to, :from, :heading, :body
end
TypeDirectory = ::WsdlMapper::Deserializers::TypeDirectory.new
NoteTypeDeserializer = TypeDirectory.register_type([nil, 'noteType'], NoteType) do
  register_prop(:to, [nil, 'to'], ['http://www.w3.org/2001/XMLSchema', 'string'])
  register_prop(:from, [nil, 'from'], ['http://www.w3.org/2001/XMLSchema', 'string'])
  register_prop(:heading, [nil, 'heading'], ['http://www.w3.org/2001/XMLSchema', 'string'])
  register_prop(:body, [nil, 'body'], ['http://www.w3.org/2001/XMLSchema', 'string'])
end
ElementDirectory = ::WsdlMapper::Deserializers::ElementDirectory.new(TypeDirectory) do
  register_element [nil, 'note'], [nil, 'noteType'], 'note_type_deserializer', '::NoteTypeDeserializer'

  def require(path); end
end
RUBY

    SoapArrayTestModule = <<RUBY
require "wsdl_mapper/deserializers/type_directory"
require "wsdl_mapper/deserializers/element_directory"
class NoteType
  attr_accessor :to, :from, :heading, :body, :attachments
end
class AttachmentType
  attr_accessor :name, :body
end
class AttachmentsArray < ::Array
end
TypeDirectory = ::WsdlMapper::Deserializers::TypeDirectory.new
NoteTypeDeserializer = TypeDirectory.register_type([nil, 'noteType'], NoteType) do
  register_prop(:to, [nil, 'to'], ['http://www.w3.org/2001/XMLSchema', 'string'])
  register_prop(:from, [nil, 'from'], ['http://www.w3.org/2001/XMLSchema', 'string'])
  register_prop(:heading, [nil, 'heading'], ['http://www.w3.org/2001/XMLSchema', 'string'])
  register_prop(:body, [nil, 'body'], ['http://www.w3.org/2001/XMLSchema', 'string'])
  register_prop(:attachments, [nil, 'attachments'], [nil, 'attachmentsArray'])
end
AttachmentDeserializer = TypeDirectory.register_type([nil, 'attachment'], AttachmentType) do
  register_prop(:name, [nil, 'name'], ['http://www.w3.org/2001/XMLSchema', 'string'])
  register_prop(:body, [nil, 'body'], ['http://www.w3.org/2001/XMLSchema', 'string'])
end
AttachmentsArrayDeserializer = TypeDirectory.register_soap_array([nil, 'attachmentsArray'], AttachmentsArray, [nil, 'attachment'])
ElementDirectory = ::WsdlMapper::Deserializers::ElementDirectory.new(TypeDirectory) do
  register_element [nil, 'note'], [nil, 'noteType'], 'note_type_deserializer', '::NoteTypeDeserializer'

  def require(path); end
end
RUBY

    def test_with_soap_array
      test_module = create_test_module SoapArrayTestModule

      xml = <<XML
<?xml version="1.0" encoding="UTF-8"?>
<note>
  <to>to@example.org</to>
  <from>from@example.org</from>
  <heading>This is the subject</heading>
  <body>This is the body</body>
  <attachments xmlns:ns0="http://schemas.xmlsoap.org/soap/encoding/" ns0:arrayType="attachment[2]">
    <attachment>
      <name>This is an attachment</name>
    </attachment>
    <attachment>
      <name>This is another attachment</name>
    </attachment>
  </attachments>
</note>
XML

      deserializer = LazyLoadingDeserializer.new test_module.const_get('ElementDirectory')
      obj = deserializer.from_xml xml

      assert_kind_of test_module.const_get(:NoteType), obj
      assert_kind_of test_module.const_get(:AttachmentsArray), obj.attachments
      assert_equal 2, obj.attachments.count
      assert_equal 'This is an attachment', obj.attachments.first.name
    end

    def test_integration
      test_module = create_test_module TestModule1

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
