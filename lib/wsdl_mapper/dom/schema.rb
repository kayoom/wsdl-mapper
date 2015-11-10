require 'wsdl_mapper/dom/builtin_type'
require 'wsdl_mapper/dom/soap_encoding_type'
require 'wsdl_mapper/dom/directory'

module WsdlMapper
  module Dom
    class Schema
      include WsdlMapper::Dom

      attr_reader :types, :imports, :elements
      attr_accessor :target_namespace, :qualified_elements, :qualified_attributes

      def initialize
        @types = Directory.new
        @elements = Directory.new
        @builtin_types = Directory.new
        @soap_encoding_types = Directory.new
        @qualified_elements = false
        @qualified_attributes = false
        @imports = []
      end

      def add_import ns, schema
        @imports << schema
      end

      def add_type type
        @types[type.name] = type
      end

      def add_element element
        @elements[element.name] = element
      end

      def get_type name
        if name.ns == BuiltinType::NAMESPACE
          @builtin_types[name] ||= BuiltinType.types[name]
        elsif name.ns == SoapEncodingType::NAMESPACE
          @soap_encoding_types[name] ||= SoapEncodingType.types[name]
        elsif type = @types[name]
          type
        else
          @imports.lazy.map { |s| s.get_type(name) }.reject(&:nil?).first
        end
      end

      def get_element name
        @elements[name]
      end

      def each_type &block
        enum = Enumerator.new do |y|
          @types.each do |(n, t)|
            y << t
          end
          @imports.each do |i|
            i.each_type do |t|
              y << t
            end
          end
        end

        block_given? ? enum.each(&block) : enum
      end

      def each_element &block
        enum = Enumerator.new do |y|
          @elements.each do |(n, t)|
            y << t
          end
          @imports.each do |i|
            i.each_element do |t|
              y << t
            end
          end
        end

        block_given? ? enum.each(&block) : enum
      end

      def each_builtin_type &block
        @builtin_types.values.each &block
      end

      def each_soap_encoding_type &block
        @soap_encoding_types.values.each &block
      end
    end
  end
end
