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
      WsdlMapper::Dom::Name.get WsdlMapper::Dom::BuiltinType::NAMESPACE, name
    end

    class NoteType
      attr_accessor :to, :date_time, :uuid, :attachments
    end

    class AttachmentType
      attr_accessor :name, :content
    end

    AttachmentTypeMapping = ClassMapping.new AttachmentType do
      register_prop :name, WsdlMapper::Dom::Name.get(nil, 'name'), BUILTIN['string']
      register_prop :content, WsdlMapper::Dom::Name.get(nil, 'body'), BUILTIN['base64Binary']
    end

    NoteTypeMapping = ClassMapping.new NoteType do
      register_attr :uuid, WsdlMapper::Dom::Name.get(nil, 'uuid'), BUILTIN['token']
      register_prop :to, WsdlMapper::Dom::Name.get(nil, 'to'), BUILTIN['string']
      register_prop :date_time, WsdlMapper::Dom::Name.get(nil, 'dateTime'), BUILTIN['dateTime']
      register_prop :attachments, WsdlMapper::Dom::Name.get(nil, 'attachment'), WsdlMapper::Dom::Name.new(nil, 'attachmentType'), array: true
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
      deserializer.register Name.get(nil, "noteType"), NoteTypeMapping

      obj = deserializer.from_xml xml
      assert_kind_of NoteType, obj
      assert_equal "ABCD-1234", obj.uuid
      assert_equal "to@example.org", obj.to
      assert_equal ::DateTime.new(2002, 5, 30, 9, 30, 10, '-6'), obj.date_time
    end

    def test_nested_example
      xml = <<XML
<?xml version="1.0" encoding="UTF-8"?>
<noteType uuid="ABCD-1234">
  <to>to@example.org</to>
  <dateTime>2002-05-30T09:30:10-06:00</dateTime>
  <attachment>
    <name>This is an attachment.</name>
    <body>SW50ZWdlciBwb3N1ZXJlIGVyYXQgYSBhbnRlIHZlbmVuYXRpcyBkYXBpYnVzIHBvc3VlcmUgdmVsaXQgYWxpcXVldC4gRG9uZWMgc2VkIG9kaW8gZHVpLiBDdXJhYml0dXIgYmxhbmRpdCB0ZW1wdXMgcG9ydHRpdG9yLiBWaXZhbXVzIHNhZ2l0dGlzIGxhY3VzIHZlbCBhdWd1ZSBsYW9yZWV0IHJ1dHJ1bSBmYXVjaWJ1cyBkb2xvciBhdWN0b3IuIEludGVnZXIgcG9zdWVyZSBlcmF0IGEgYW50ZSB2ZW5lbmF0aXMgZGFwaWJ1cyBwb3N1ZXJlIHZlbGl0IGFsaXF1ZXQuIE51bGxhbSBxdWlzIHJpc3VzIGVnZXQgdXJuYSBtb2xsaXMgb3JuYXJlIHZlbCBldSBsZW8uIE51bGxhIHZpdGFlIGVsaXQgbGliZXJvLCBhIHBoYXJldHJhIGF1Z3VlLg==</body>
  </attachment>
</noteType>
XML

      deserializer = Deserializer.new
      deserializer.register Name.get(nil, "noteType"), NoteTypeMapping
      deserializer.register Name.get(nil, "attachmentType"), AttachmentTypeMapping

      obj = deserializer.from_xml xml
      assert_kind_of NoteType, obj

      att = obj.attachments.first
      assert_kind_of AttachmentType, att
      assert_equal "This is an attachment.", att.name

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
      register_prop :name, WsdlMapper::Dom::Name.get(nil, 'name'), BUILTIN['string']
      register_prop :supervisor, WsdlMapper::Dom::Name.get(nil, 'supervisor'), WsdlMapper::Dom::Name.get(nil, 'userType')
    end

    ConversationMapping = ClassMapping.new Conversation do
      register_prop :notes, WsdlMapper::Dom::Name.get(nil, 'note'), WsdlMapper::Dom::Name.get(nil, 'noteType'), array: true
    end

    CaseMapping = ClassMapping.new Case do
      register_prop :author, WsdlMapper::Dom::Name.get(nil, 'author'), WsdlMapper::Dom::Name.get(nil, 'userType')
      register_prop :conversation, WsdlMapper::Dom::Name.get(nil, 'conversation'), WsdlMapper::Dom::Name.get(nil, 'conversationType')
    end

    def test_complex_example
      xml = <<XML
<?xml version="1.0" encoding="UTF-8"?>
<caseType>
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
</caseType>
XML

      deserializer = Deserializer.new
      deserializer.register Name.get(nil, "noteType"), NoteTypeMapping
      deserializer.register Name.get(nil, "attachmentType"), AttachmentTypeMapping
      deserializer.register Name.get(nil, "userType"), UserMapping
      deserializer.register Name.get(nil, "conversationType"), ConversationMapping
      deserializer.register Name.get(nil, "caseType"), CaseMapping

      obj = deserializer.from_xml xml
      assert_kind_of Case, obj

      author = obj.author
      assert_kind_of User, author
      assert_equal "Mr. Bean", author.name

      supervisor = author.supervisor
      assert_kind_of User, supervisor
      assert_equal "James Bond", supervisor.name

      conv = obj.conversation
      assert_kind_of Conversation, conv

      notes = conv.notes
      note = notes.first
      assert_kind_of NoteType, note
      assert_equal "ABCD-1234", note.uuid
      assert_equal "to@example.org", note.to

      att = note.attachments.first
      assert_kind_of AttachmentType, att
      assert_equal "This is an attachment.", att.name

      assert_kind_of StringIO, att.content
      assert_equal <<TXT.strip, att.content.read
Integer posuere erat a ante venenatis dapibus posuere velit aliquet. Donec sed odio dui. Curabitur blandit tempus porttitor. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Integer posuere erat a ante venenatis dapibus posuere velit aliquet. Nullam quis risus eget urna mollis ornare vel eu leo. Nulla vitae elit libero, a pharetra augue.
TXT
    end

    def test_soap_array
      skip # TODO: soap array
    end
  end
end
