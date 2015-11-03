require 'test_helper'

require 'wsdl_mapper/dom/name'
require 'wsdl_mapper/serializers/base'
require 'wsdl_mapper/core_ext/time_duration'

module SerializersTests
  class BaseTest < ::Minitest::Test
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
        x.complex 'noteType' do |x|
          obj.attachments.each do |attachment|
            x.get('serializers/attachment_serializer').build(x, attachment)
          end
        end
      end
    end

    class AttachmentSerializer
      def build x, obj
        x.simple 'attachment' do |x|
          x.text_builtin obj, "string"
        end
      end
    end

    def test_resolving
      resolver = MockResolver.new
      resolver.serializers['serializers/attachment_serializer'] = AttachmentSerializer.new

      base = Base.new resolver: resolver

      obj = NoteType.new([Attachment.new("This is an attachment.")])

      NoteTypeSerializer.new.build base, obj

      assert_equal <<XML, base.to_xml
<?xml version="1.0" encoding="UTF-8"?>
<noteType>
  <attachment>This is an attachment.</attachment>
</noteType>
XML
    end

    def test_simple_example
      base = Base.new resolver: nil

      base.complex 'noteType' do |x|
        x.value_builtin :to, "to@example.org", :string
        x.value_builtin :from, "from@example.org", :string
        x.value_builtin :date, DateTime.new(2010, 11, 10, 9, 8, 7, "+02:00"), :dateTime
        x.value_builtin :valid_for, TimeDuration.new(days: 20), :gDay
        x.value_builtin :heading, "Important Note!", :string
        x.value_builtin :body, "Just kidding", :string
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

    def test_nested_example
      base = Base.new resolver: nil

      base.complex 'noteType' do |x|
        x.complex 'noteHeader' do |x|
          x.value_builtin :to, "to@example.org", :string
          x.value_builtin :from, "from@example.org", :string
          x.value_builtin :date, DateTime.new(2010, 11, 10, 9, 8, 7, "+02:00"), :dateTime
          x.value_builtin :valid_for, TimeDuration.new(days: 20), :gDay
          x.value_builtin :heading, "Important Note!", :string
        end
        x.value_builtin :body, "Just kidding", :string
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
      base = Base.new resolver: nil

      attributes = [
        [[base.soap_enc, "arrayType"], "attachment[2]", "string"]
      ]
      base.complex "attachments", attributes do |x|
        x.complex "attachment" do |x|
          x.value_builtin :name, "This is an attachment", :string
        end
        x.complex "attachment" do |x|
          x.value_builtin :name, "This is another attachment", :string
        end
      end

      assert_equal <<XML, base.to_xml
<?xml version="1.0" encoding="UTF-8"?>
<attachments xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" soapenc:arrayType="attachment[2]">
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
      base = Base.new resolver: nil

      attributes = [
        ["uuid", nil, "token"]
      ]
      base.complex 'noteType', attributes do |x|
        x.value_builtin :to, "to@example.org", :string
        x.value_builtin :from, "from@example.org", :string
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
      base = Base.new resolver: nil

      attributes = [
        ["uuid", "12345", "token"]
      ]
      base.complex 'noteType', attributes do |x|
        x.value_builtin :to, "to@example.org", :string
        x.value_builtin :from, "from@example.org", :string
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
