require 'test_helper'

require 'wsdl_mapper/dom/name'
require 'wsdl_mapper/serializers/serializer'
require 'wsdl_mapper/core_ext/time_duration'

module SerializersTests
  class SerializerTest < ::Minitest::Test
    include WsdlMapper::CoreExt
    include WsdlMapper::Serializers
    include WsdlMapper::Dom

    class MockResolver
      def initialize
        @serializers = {}
      end

      def resolve name
        serializers[name]
      end

      def serializers
        @serializers ||= {}
      end
    end

    class NoteType < Struct.new(:attachments)
    end

    class Attachment < String
    end

    class NoteTypeSerializer
      def build x, obj
        x.complex nil, 'noteType', [] do |x|
          obj.attachments.each do |attachment|
            x.get('serializers/attachment_serializer').build(x, attachment)
          end
        end
      end
    end

    class AttachmentSerializer
      def build x, obj
        x.simple nil, 'attachment' do |x|
          x.text_builtin obj, "string"
        end
      end
    end

    def test_resolving
      resolver = MockResolver.new
      resolver.serializers['serializers/attachment_serializer'] = AttachmentSerializer.new

      base = Serializer.new resolver: resolver

      obj = NoteType.new([Attachment.new("This is an attachment.")])

      NoteTypeSerializer.new.build base, obj

      assert_equal <<XML, base.to_xml
<?xml version="1.0" encoding="UTF-8"?>
<noteType>
  <attachment>This is an attachment.</attachment>
</noteType>
XML
    end

    def test_simple_example_with_namespace
      base = Serializer.new resolver: nil

      base.complex 'urn:WsdlMapper', 'noteType', [] do |x|
        x.value_builtin 'urn:WsdlMapper', :to, "to@example.org", :string
        x.value_builtin 'urn:WsdlMapper', :from, "from@example.org", :string
        x.value_builtin 'urn:WsdlMapper', :date, DateTime.new(2010, 11, 10, 9, 8, 7, "+02:00"), :dateTime
        x.value_builtin 'urn:WsdlMapper', :valid_for, TimeDuration.new(days: 20), :gDay
        x.value_builtin 'urn:WsdlMapper', :heading, "Important Note!", :string
        x.value_builtin 'urn:WsdlMapper', :body, "Just kidding", :string
      end

      assert_equal <<XML, base.to_xml
<?xml version="1.0" encoding="UTF-8"?>
<ns0:noteType xmlns:ns0="urn:WsdlMapper">
  <ns0:to>to@example.org</ns0:to>
  <ns0:from>from@example.org</ns0:from>
  <ns0:date>2010-11-10T09:08:07+02:00</ns0:date>
  <ns0:valid_for>20</ns0:valid_for>
  <ns0:heading>Important Note!</ns0:heading>
  <ns0:body>Just kidding</ns0:body>
</ns0:noteType>
XML
    end

    def test_simple_example_with_namespace_and_default
      base = Serializer.new resolver: nil, default_namespace: 'urn:WsdlMapper'

      base.complex 'urn:WsdlMapper', 'noteType', [] do |x|
        x.value_builtin 'urn:WsdlMapper', :to, "to@example.org", :string
        x.value_builtin 'urn:WsdlMapper', :from, "from@example.org", :string
        x.value_builtin 'urn:WsdlMapper', :date, DateTime.new(2010, 11, 10, 9, 8, 7, "+02:00"), :dateTime
        x.value_builtin 'urn:WsdlMapper', :valid_for, TimeDuration.new(days: 20), :gDay
        x.value_builtin 'urn:WsdlMapper', :heading, "Important Note!", :string
        x.value_builtin 'urn:WsdlMapper', :body, "Just kidding", :string
      end

      assert_equal <<XML, base.to_xml
<?xml version="1.0" encoding="UTF-8"?>
<noteType xmlns="urn:WsdlMapper">
  <to>to@example.org</to>
  <from>from@example.org</from>
  <date>2010-11-10T09:08:07+02:00</date>
  <valid_for>20</valid_for>
  <heading>Important Note!</heading>
  <body>Just kidding</body>
</noteType>
XML
    end

    def test_simple_example_with_namespace_and_custom_prefix
      namespaces = WsdlMapper::Dom::Namespaces.new
      namespaces[:wm] = 'urn:WsdlMapper'
      base = Serializer.new resolver: nil, namespaces: namespaces

      base.complex 'urn:WsdlMapper', 'noteType', [] do |x|
        x.value_builtin 'urn:WsdlMapper', :to, "to@example.org", :string
        x.value_builtin 'urn:WsdlMapper', :from, "from@example.org", :string
        x.value_builtin 'urn:WsdlMapper', :date, DateTime.new(2010, 11, 10, 9, 8, 7, "+02:00"), :dateTime
        x.value_builtin 'urn:WsdlMapper', :valid_for, TimeDuration.new(days: 20), :gDay
        x.value_builtin 'urn:WsdlMapper', :heading, "Important Note!", :string
        x.value_builtin 'urn:WsdlMapper', :body, "Just kidding", :string
      end

      assert_equal <<XML, base.to_xml
<?xml version="1.0" encoding="UTF-8"?>
<wm:noteType xmlns:wm="urn:WsdlMapper">
  <wm:to>to@example.org</wm:to>
  <wm:from>from@example.org</wm:from>
  <wm:date>2010-11-10T09:08:07+02:00</wm:date>
  <wm:valid_for>20</wm:valid_for>
  <wm:heading>Important Note!</wm:heading>
  <wm:body>Just kidding</wm:body>
</wm:noteType>
XML
    end

    def test_simple_example
      base = Serializer.new resolver: nil

      base.complex nil, 'noteType', [] do |x|
        x.value_builtin nil, :to, "to@example.org", :string
        x.value_builtin nil, :from, "from@example.org", :string
        x.value_builtin nil, :date, DateTime.new(2010, 11, 10, 9, 8, 7, "+02:00"), :dateTime
        x.value_builtin nil, :valid_for, TimeDuration.new(days: 20), :gDay
        x.value_builtin nil, :heading, "Important Note!", :string
        x.value_builtin nil, :body, "Just kidding", :string
      end

      assert_equal <<XML, base.to_xml
<?xml version="1.0" encoding="UTF-8"?>
<noteType>
  <to>to@example.org</to>
  <from>from@example.org</from>
  <date>2010-11-10T09:08:07+02:00</date>
  <valid_for>20</valid_for>
  <heading>Important Note!</heading>
  <body>Just kidding</body>
</noteType>
XML
    end

    def test_simple_example_with_default_namespace
      base = Serializer.new resolver: nil, default_namespace: "http://example.org/schema"

      base.complex nil, 'noteType', [] do |x|
        x.value_builtin nil, :to, "to@example.org", :string
        x.value_builtin nil, :from, "from@example.org", :string
        x.value_builtin nil, :date, DateTime.new(2010, 11, 10, 9, 8, 7, "+02:00"), :dateTime
        x.value_builtin nil, :valid_for, TimeDuration.new(days: 20), :gDay
        x.value_builtin nil, :heading, "Important Note!", :string
        x.value_builtin nil, :body, "Just kidding", :string
      end

      assert_equal <<XML, base.to_xml
<?xml version="1.0" encoding="UTF-8"?>
<noteType xmlns="http://example.org/schema">
  <to>to@example.org</to>
  <from>from@example.org</from>
  <date>2010-11-10T09:08:07+02:00</date>
  <valid_for>20</valid_for>
  <heading>Important Note!</heading>
  <body>Just kidding</body>
</noteType>
XML
    end

    def test_nested_example
      base = Serializer.new resolver: nil

      base.complex nil, 'noteType', [] do |x|
        x.complex nil, 'noteHeader', [] do |x|
          x.value_builtin nil, :to, "to@example.org", :string
          x.value_builtin nil, :from, "from@example.org", :string
          x.value_builtin nil, :date, DateTime.new(2010, 11, 10, 9, 8, 7, "+02:00"), :dateTime
          x.value_builtin nil, :valid_for, TimeDuration.new(days: 20), :gDay
          x.value_builtin nil, :heading, "Important Note!", :string
        end
        x.value_builtin nil, :body, "Just kidding", :string
      end

      assert_equal <<XML, base.to_xml
<?xml version="1.0" encoding="UTF-8"?>
<noteType>
  <noteHeader>
    <to>to@example.org</to>
    <from>from@example.org</from>
    <date>2010-11-10T09:08:07+02:00</date>
    <valid_for>20</valid_for>
    <heading>Important Note!</heading>
  </noteHeader>
  <body>Just kidding</body>
</noteType>
XML
    end

    def test_soap_array
      base = Serializer.new resolver: nil

      attributes = [
        [base.soap_enc, "arrayType", "attachment[2]", "string"]
      ]
      base.complex nil, "attachments", attributes do |x|
        x.complex nil, "attachment", [] do |x|
          x.value_builtin nil, :name, "This is an attachment", :string
        end
        x.complex nil, "attachment", [] do |x|
          x.value_builtin nil, :name, "This is another attachment", :string
        end
      end

      assert_equal <<XML, base.to_xml
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
    end

    def test_nil_attribute
      base = Serializer.new resolver: nil

      attributes = [
        [nil, "uuid", nil, "token"]
      ]
      base.complex nil, 'noteType', attributes do |x|
        x.value_builtin nil, :to, "to@example.org", :string
        x.value_builtin nil, :from, "from@example.org", :string
      end

      assert_equal <<XML, base.to_xml
<?xml version="1.0" encoding="UTF-8"?>
<noteType>
  <to>to@example.org</to>
  <from>from@example.org</from>
</noteType>
XML
    end

    def test_simple_example_with_attributes
      base = Serializer.new resolver: nil

      attributes = [
        [nil, "uuid", "12345", "token"]
      ]
      base.complex nil, 'noteType', attributes do |x|
        x.value_builtin nil, :to, "to@example.org", :string
        x.value_builtin nil, :from, "from@example.org", :string
      end

      assert_equal <<XML, base.to_xml
<?xml version="1.0" encoding="UTF-8"?>
<noteType uuid="12345">
  <to>to@example.org</to>
  <from>from@example.org</from>
</noteType>
XML
    end
  end
end
