require 'test_helper'

require 'wsdl_mapper/dom/name'
require 'wsdl_mapper/deserializers/deserializer'
require 'wsdl_mapper/core_ext/time_duration'

module DeserializersTests
  class DeserializerWithNsTest < ::WsdlMapperTesting::Test
    include WsdlMapper::CoreExt
    include WsdlMapper::Dom
    include WsdlMapper::Deserializers

    BUILTIN = lambda do |name|
      [BuiltinType::NAMESPACE, name]
    end

    NS1 = 'http://example.org/schema1'
    NS2 = 'http://example.org/schema2'

    class NoteType
      attr_accessor :to, :date_time, :uuid, :attachments
    end

    NoteTypeMapping = ClassMapping.new NoteType do
      register_attr(:uuid, [NS1, 'uuid'], BUILTIN['token'])
      register_prop(:to, [NS1, 'to'], BUILTIN['string'])
      register_prop(:date_time, [NS1, 'dateTime'], BUILTIN['dateTime'])
      register_prop(:attachments, [NS1, 'attachment'], [NS1, 'attachmentType'], array: true)
    end

    class AttachmentType
      attr_accessor :name, :content
    end

    AttachmentTypeMapping = ClassMapping.new AttachmentType do
      register_prop(:name, [NS1, 'name'], BUILTIN['string'])
      register_prop(:content, [NS1, 'body'], BUILTIN['base64Binary'])
    end

    class User
      attr_accessor :name, :supervisor
    end

    UserMapping = ClassMapping.new User do
      register_prop(:name, [NS2, 'name'], BUILTIN['string'])
      register_prop(:supervisor, [NS2, 'supervisor'], [NS2, 'userType'])
    end

    class Conversation
      attr_accessor :notes
    end

    ConversationMapping = ClassMapping.new Conversation do
      register_prop(:notes, [NS2, 'note'], [NS1, 'noteType'], array: true)
    end

    class Case
      attr_accessor :author, :conversation
    end

    CaseMapping = ClassMapping.new Case do
      register_prop(:author, [NS2, 'author'], [NS2, 'userType'])
      register_prop(:conversation, [NS2, 'conversation'], [NS2, 'conversationType'])
    end

    def test_fully_qualified_example
      xml = <<XML
<?xml version="1.0" encoding="UTF-8"?>
<ns2:case xmlns:ns1="http://example.org/schema1" xmlns:ns2="http://example.org/schema2">
  <ns2:author>
    <ns2:name>Mr. Bean</ns2:name>
    <ns2:supervisor>
      <ns2:name>James Bond</ns2:name>
    </ns2:supervisor>
  </ns2:author>
  <ns2:conversation>
    <ns2:note ns1:uuid="ABCD-1234">
      <ns1:to>to@example.org</ns1:to>
      <ns1:dateTime>2002-05-30T09:30:10-06:00</ns1:dateTime>
      <ns1:attachment>
        <ns1:name>This is an attachment.</ns1:name>
        <ns1:body>SW50ZWdlciBwb3N1ZXJlIGVyYXQgYSBhbnRlIHZlbmVuYXRpcyBkYXBpYnVzIHBvc3VlcmUgdmVsaXQgYWxpcXVldC4gRG9uZWMgc2VkIG9kaW8gZHVpLiBDdXJhYml0dXIgYmxhbmRpdCB0ZW1wdXMgcG9ydHRpdG9yLiBWaXZhbXVzIHNhZ2l0dGlzIGxhY3VzIHZlbCBhdWd1ZSBsYW9yZWV0IHJ1dHJ1bSBmYXVjaWJ1cyBkb2xvciBhdWN0b3IuIEludGVnZXIgcG9zdWVyZSBlcmF0IGEgYW50ZSB2ZW5lbmF0aXMgZGFwaWJ1cyBwb3N1ZXJlIHZlbGl0IGFsaXF1ZXQuIE51bGxhbSBxdWlzIHJpc3VzIGVnZXQgdXJuYSBtb2xsaXMgb3JuYXJlIHZlbCBldSBsZW8uIE51bGxhIHZpdGFlIGVsaXQgbGliZXJvLCBhIHBoYXJldHJhIGF1Z3VlLg==</ns1:body>
      </ns1:attachment>
    </ns2:note>
  </ns2:conversation>
</ns2:case>
XML

      deserializer = Deserializer.new
      deserializer.register_type [NS1, 'noteType'], NoteTypeMapping
      deserializer.register_type [NS1, 'attachmentType'], AttachmentTypeMapping
      deserializer.register_type [NS2, 'userType'], UserMapping
      deserializer.register_type [NS2, 'conversationType'], ConversationMapping
      deserializer.register_type [NS2, 'caseType'], CaseMapping
      deserializer.register_element [NS2, 'case'], [NS2, 'caseType']

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

    def test_partially_qualified_example
      xml = <<XML
<?xml version="1.0" encoding="UTF-8"?>
<ns2:case xmlns:ns1="http://example.org/schema1" xmlns:ns2="http://example.org/schema2">
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
</ns2:case>
XML

      deserializer = Deserializer.new
      deserializer.register_type [NS1, 'noteType'], NoteTypeMapping
      deserializer.register_type [NS1, 'attachmentType'], AttachmentTypeMapping
      deserializer.register_type [NS2, 'userType'], UserMapping
      deserializer.register_type [NS2, 'conversationType'], ConversationMapping
      deserializer.register_type [NS2, 'caseType'], CaseMapping
      deserializer.register_element [NS2, 'case'], [NS2, 'caseType']

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
  end
end
