require 'nokogiri'

require 'wsdl_mapper/dom/name'
require 'wsdl_mapper/dom/namespaces'
require 'wsdl_mapper/type_mapping'

module WsdlMapper
  module Deserializers
    class Deserializer
      include WsdlMapper::Dom

      class AttrMapping < Struct.new(:accessor, :name, :type_name)
        def getter
          accessor
        end

        def setter
          "#{accessor}="
        end

        def get obj
          obj.send getter
        end

        def set obj, value
          obj.send setter, value
        end
      end

      class Mapping
        attr_reader :attributes, :properties

        def initialize cls, &block
          @cls = cls
          @attributes = {}
          @properties = {}
          instance_exec &block
        end

        def register_attr accessor, name, type
          @attributes[name] = AttrMapping.new(accessor, name, type)
        end

        def register_prop accessor, name, type
          @properties[name] = AttrMapping.new(accessor, name, type)
        end

        def start base, frame
          frame.object = @cls.new
          set_attributes base, frame
        end

        def end base, frame
          set_properties base, frame
        end

        def set_properties base, frame
          frame.children.each do |child|
            name = child.name
            prop_mapping = properties[name]
            ruby_value = base.to_ruby prop_mapping.type_name, child.text
            prop_mapping.set frame.object, ruby_value
          end
        end

        def set_attributes base, frame
          frame.attrs.each do |attr|
            name = WsdlMapper::Dom::Name.new attr.uri, attr.localname
            attr_mapping = attributes[name]
            ruby_value = base.to_ruby attr_mapping.type_name, attr.value
            attr_mapping.set frame.object, ruby_value
          end
        end
      end

      class Frame
        attr_reader :name, :parent, :attrs, :base, :deserializer, :namespaces, :children
        attr_accessor :text, :object

        def initialize name, attrs, parent, namespaces, base
          @name = name
          @parent = parent
          @attrs = attrs
          @namespaces = namespaces
          @base = base
          @deserializer = @base.get name
          @children = []
        end

        def start
          if @deserializer
            @deserializer.start @base, self
          end
        end

        def end
          if @deserializer
            @deserializer.end @base, self
          end
        end
      end

      class Document < ::Nokogiri::XML::SAX::Document
        include WsdlMapper::Dom

        attr_reader :object

        def initialize base
          @base = base
        end

        def start_element_namespace name, attrs = [], prefix = nil, uri = nil, ns = []
          @buffer = ""
          name = Name.new uri, name
          namespaces = Namespaces.new
          ns.each do |namespace|
            namespaces.set *namespace
          end
          @current_frame = Frame.new name, attrs, @current_frame, namespaces, @base
          @current_frame.start
        end

        def end_element_namespace name, prefix = nil, uri = nil
          @current_frame.text = @buffer
          @buffer = ""
          @last_frame = @current_frame
          @current_frame = @current_frame.parent
          if @current_frame
            @current_frame.children << @last_frame
          end
          @last_frame.end
        end

        def end_document
          @object = @last_frame.object
        end

        def start_document
        end

        def characters text
          @buffer += text
        end
      end

      def initialize
        @tm = ::WsdlMapper::TypeMapping::DEFAULT
        @deserializers = {}
      end

      def from_xml xml
        doc = Document.new self
        parser = Nokogiri::XML::SAX::Parser.new doc
        parser.parse xml
        doc.object
      end

      def register name, deserializer
        @deserializers[name] = deserializer
      end

      def get name
        @deserializers[name]
      end

      def to_ruby type, value
        @tm.to_ruby type, value
      end
    end
  end
end
