require 'test_helper'

require 'wsdl_mapper/dom/name'
require 'wsdl_mapper/deserializers/deserializer'
require 'wsdl_mapper/core_ext/time_duration'

module DeserializersTests
  class DeserializerTest < ::Minitest::Test
    include WsdlMapper::CoreExt
    include WsdlMapper::Dom
    include WsdlMapper::Deserializers

    BUILTIN = lambda do |name|
      [WsdlMapper::Dom::BuiltinType::NAMESPACE, name]
    end

    class NoteType
      attr_accessor :to, :date_time, :uuid, :attachments
    end

    class AttachmentType
      attr_accessor :name, :content
    end

    AttachmentTypeMapping = ClassMapping.new AttachmentType do
      register_prop :name, [nil, 'name'], BUILTIN['string']
      register_prop :content, [nil, 'body'], BUILTIN['base64Binary']
    end

    NoteTypeMapping = ClassMapping.new NoteType do
      register_attr :uuid, [nil, 'uuid'], BUILTIN['token']
      register_prop :to, [nil, 'to'], BUILTIN['string']
      register_prop :date_time, [nil, 'dateTime'], BUILTIN['dateTime']
      register_prop :attachments, [nil, 'attachment'], [nil, 'attachmentType'], array: true
    end

    class MoneyType
      attr_accessor :content, :currency

      def initialize content
        @content = content
      end
    end

    MoneyTypeMapping = ClassMapping.new MoneyType, simple: ['http://www.w3.org/2001/XMLSchema', 'double'] do
      register_attr :currency, [nil, 'currency'], BUILTIN['token']
    end

    def test_register_type
      deserializer = Deserializer.new

      deserializer.register_type [nil, 'noteType'], NoteTypeMapping

      assert_equal NoteTypeMapping, deserializer.get_type_mapping(Name.get(nil, 'noteType'))
    end

    def test_register_root_element
      deserializer = Deserializer.new

      deserializer.register_element [nil, 'note'], [nil, 'noteType']
      deserializer.register_type [nil, 'noteType'], NoteTypeMapping

      assert_equal Name.get(nil, 'noteType'), deserializer.get_element_type(Name.get(nil, 'note'))
      assert_equal NoteTypeMapping, deserializer.get_element_type_mapping(Name.get(nil, 'note'))
    end

    def test_simple_example
      xml = <<XML
<?xml version="1.0" encoding="UTF-8"?>
<note uuid="ABCD-1234">
  <to>to@example.org</to>
  <dateTime>2002-05-30T09:30:10-06:00</dateTime>
</note>
XML

      deserializer = Deserializer.new
      deserializer.register_element [nil, 'note'], [nil, 'noteType']
      deserializer.register_type [nil, 'noteType'], NoteTypeMapping

      obj = deserializer.from_xml xml
      assert_kind_of NoteType, obj
      assert_equal 'ABCD-1234', obj.uuid
      assert_equal 'to@example.org', obj.to
      assert_equal ::DateTime.new(2002, 5, 30, 9, 30, 10, '-6'), obj.date_time
    end

    def test_simple_content
      xml = <<XML
<?xml version="1.0" encoding="UTF-8"?>
<money currency="EUR">
  123.45
</money>
XML

      deserializer = Deserializer.new
      deserializer.register_element [nil, 'money'], [nil, 'moneyType']
      deserializer.register_type [nil, 'moneyType'], MoneyTypeMapping

      obj = deserializer.from_xml xml
      assert_kind_of MoneyType, obj
      assert_equal 'EUR', obj.currency
      assert_equal 123.45, obj.content
    end

    def test_raise_on_unknown_element
      xml = <<XML
<?xml version="1.0" encoding="UTF-8"?>
<note uuid="ABCD-1234">
  <to>to@example.org</to>
  <dateTime>2002-05-30T09:30:10-06:00</dateTime>
  <something-unknown></something-unknown>
</note>
XML

      deserializer = Deserializer.new
      deserializer.register_element [nil, 'note'], [nil, 'noteType']
      deserializer.register_type [nil, 'noteType'], NoteTypeMapping

      error = nil
      begin
        deserializer.from_xml xml
      rescue => e
        error = e
      end

      assert_kind_of Errors::UnknownElementError, error
      assert_equal Name.get(nil, 'something-unknown'), error.name
    end

    def test_raise_on_unknown_root
      xml = <<XML
<?xml version="1.0" encoding="UTF-8"?>
<something-unknown></something-unknown>
XML

      deserializer = Deserializer.new

      error = nil
      begin
        deserializer.from_xml xml
      rescue => e
        error = e
      end

      assert_kind_of Errors::UnknownElementError, error
      assert_equal Name.get(nil, 'something-unknown'), error.name
    end

    def test_raise_on_unknown_attribute
      xml = <<XML
<?xml version="1.0" encoding="UTF-8"?>
<note uuid="ABCD-1234" something-unknown="Foo">
  <to>to@example.org</to>
  <dateTime>2002-05-30T09:30:10-06:00</dateTime>
</note>
XML

      deserializer = Deserializer.new
      deserializer.register_element [nil, 'note'], [nil, 'noteType']
      deserializer.register_type [nil, 'noteType'], NoteTypeMapping

      error = nil
      begin
        deserializer.from_xml xml
      rescue => e
        error = e
      end

      assert_kind_of Errors::UnknownAttributeError, error
      assert_equal Name.get(nil, 'something-unknown'), error.name
    end

    def test_nested_example
      xml = <<XML
<?xml version="1.0" encoding="UTF-8"?>
<note uuid="ABCD-1234">
  <to>to@example.org</to>
  <dateTime>2002-05-30T09:30:10-06:00</dateTime>
  <attachment>
    <name>This is an attachment.</name>
    <body>SW50ZWdlciBwb3N1ZXJlIGVyYXQgYSBhbnRlIHZlbmVuYXRpcyBkYXBpYnVzIHBvc3VlcmUgdmVsaXQgYWxpcXVldC4gRG9uZWMgc2VkIG9kaW8gZHVpLiBDdXJhYml0dXIgYmxhbmRpdCB0ZW1wdXMgcG9ydHRpdG9yLiBWaXZhbXVzIHNhZ2l0dGlzIGxhY3VzIHZlbCBhdWd1ZSBsYW9yZWV0IHJ1dHJ1bSBmYXVjaWJ1cyBkb2xvciBhdWN0b3IuIEludGVnZXIgcG9zdWVyZSBlcmF0IGEgYW50ZSB2ZW5lbmF0aXMgZGFwaWJ1cyBwb3N1ZXJlIHZlbGl0IGFsaXF1ZXQuIE51bGxhbSBxdWlzIHJpc3VzIGVnZXQgdXJuYSBtb2xsaXMgb3JuYXJlIHZlbCBldSBsZW8uIE51bGxhIHZpdGFlIGVsaXQgbGliZXJvLCBhIHBoYXJldHJhIGF1Z3VlLg==</body>
  </attachment>
</note>
XML

      deserializer = Deserializer.new
      deserializer.register_element [nil, 'note'], [nil, 'noteType']
      deserializer.register_type [nil, 'noteType'], NoteTypeMapping
      deserializer.register_type [nil, 'attachmentType'], AttachmentTypeMapping

      obj = deserializer.from_xml xml
      assert_kind_of NoteType, obj

      att = obj.attachments.first
      assert_kind_of AttachmentType, att
      assert_equal 'This is an attachment.', att.name

      assert_kind_of StringIO, att.content
      assert_equal <<TXT.strip, att.content.read
Integer posuere erat a ante venenatis dapibus posuere velit aliquet. Donec sed odio dui. Curabitur blandit tempus porttitor. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Integer posuere erat a ante venenatis dapibus posuere velit aliquet. Nullam quis risus eget urna mollis ornare vel eu leo. Nulla vitae elit libero, a pharetra augue.
TXT
    end

    class User
      attr_accessor :name, :supervisor
    end

    class Conversation
      attr_accessor :notes
    end

    class Case
      attr_accessor :author, :conversation
    end

    UserMapping = ClassMapping.new User do
      register_prop :name, [nil, 'name'], BUILTIN['string']
      register_prop :supervisor, [nil, 'supervisor'], [nil, 'userType']
    end

    ConversationMapping = ClassMapping.new Conversation do
      register_prop :notes, [nil, 'note'], [nil, 'noteType'], array: true
    end

    CaseMapping = ClassMapping.new Case do
      register_prop :author, [nil, 'author'], [nil, 'userType']
      register_prop :conversation, [nil, 'conversation'], [nil, 'conversationType']
    end

    def test_complex_example
      xml = <<XML
<?xml version="1.0" encoding="UTF-8"?>
<case>
  <author>
    <name>Mr. Bean</name>
    <supervisor>
      <name>James Bond</name>
    </supervisor>
  </author>
  <conversation>
    <note uuid="ABCD-1234">
      <to>to@example.org</to>
      <dateTime>2002-05-30T09:30:10-06:00</dateTime>
      <attachment>
        <name>This is an attachment.</name>
        <body>SW50ZWdlciBwb3N1ZXJlIGVyYXQgYSBhbnRlIHZlbmVuYXRpcyBkYXBpYnVzIHBvc3VlcmUgdmVsaXQgYWxpcXVldC4gRG9uZWMgc2VkIG9kaW8gZHVpLiBDdXJhYml0dXIgYmxhbmRpdCB0ZW1wdXMgcG9ydHRpdG9yLiBWaXZhbXVzIHNhZ2l0dGlzIGxhY3VzIHZlbCBhdWd1ZSBsYW9yZWV0IHJ1dHJ1bSBmYXVjaWJ1cyBkb2xvciBhdWN0b3IuIEludGVnZXIgcG9zdWVyZSBlcmF0IGEgYW50ZSB2ZW5lbmF0aXMgZGFwaWJ1cyBwb3N1ZXJlIHZlbGl0IGFsaXF1ZXQuIE51bGxhbSBxdWlzIHJpc3VzIGVnZXQgdXJuYSBtb2xsaXMgb3JuYXJlIHZlbCBldSBsZW8uIE51bGxhIHZpdGFlIGVsaXQgbGliZXJvLCBhIHBoYXJldHJhIGF1Z3VlLg==</body>
      </attachment>
    </note>
  </conversation>
</case>
XML

      deserializer = Deserializer.new
      deserializer.register_type [nil, 'noteType'], NoteTypeMapping
      deserializer.register_type [nil, 'attachmentType'], AttachmentTypeMapping
      deserializer.register_type [nil, 'userType'], UserMapping
      deserializer.register_type [nil, 'conversationType'], ConversationMapping
      deserializer.register_type [nil, 'caseType'], CaseMapping
      deserializer.register_element [nil, 'case'], [nil, 'caseType']

      obj = deserializer.from_xml xml
      assert_kind_of Case, obj

      author = obj.author
      assert_kind_of User, author
      assert_equal 'Mr. Bean', author.name

      supervisor = author.supervisor
      assert_kind_of User, supervisor
      assert_equal 'James Bond', supervisor.name

      conv = obj.conversation
      assert_kind_of Conversation, conv

      notes = conv.notes
      note = notes.first
      assert_kind_of NoteType, note
      assert_equal 'ABCD-1234', note.uuid
      assert_equal 'to@example.org', note.to

      att = note.attachments.first
      assert_kind_of AttachmentType, att
      assert_equal 'This is an attachment.', att.name

      assert_kind_of StringIO, att.content
      assert_equal <<TXT.strip, att.content.read
Integer posuere erat a ante venenatis dapibus posuere velit aliquet. Donec sed odio dui. Curabitur blandit tempus porttitor. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Integer posuere erat a ante venenatis dapibus posuere velit aliquet. Nullam quis risus eget urna mollis ornare vel eu leo. Nulla vitae elit libero, a pharetra augue.
TXT
    end

    class AttachmentsArray < ::Array
    end

    AttachmentsArrayMapping = SoapArrayMapping.new AttachmentsArray, type: [nil, 'attachment']

    def test_soap_array
      xml = <<XML
<?xml version="1.0" encoding="UTF-8"?>
<attachments xmlns:ns0="http://schemas.xmlsoap.org/soap/encoding/" ns0:arrayType="attachment[2]">
  <attachment>
    <name>This is an attachment</name>
  </attachment>
  <attachment>
    <name>This is another attachment</name>
  </attachment>
</attachments>
XML

      deserializer = Deserializer.new
      deserializer.register_type [nil, 'attachmentsArrayType'], AttachmentsArrayMapping
      deserializer.register_type [nil, 'attachment'], AttachmentTypeMapping
      deserializer.register_element [nil, 'attachments'], [nil, 'attachmentsArrayType']

      obj = deserializer.from_xml xml

      assert_kind_of AttachmentsArray, obj
      assert_equal 2, obj.count
      assert_kind_of AttachmentType, obj.first
      assert_equal 'This is an attachment', obj.first.name
      assert_kind_of AttachmentType, obj.last
      assert_equal 'This is another attachment', obj.last.name
    end
  end
end
