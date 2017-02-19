require 'wsdl_mapper/dom/builtin_type'
require 'wsdl_mapper/dom/soap_encoding_type'
require 'wsdl_mapper/dom/directory'

module WsdlMapper
  module Dom
    class Schema
      include WsdlMapper::Dom

      attr_reader :types, :imports, :elements, :attributes, :unresolved_imports
      attr_accessor :target_namespace, :qualified_elements, :qualified_attributes

      def initialize
        @types = Directory.new
        @anon_types = []
        @elements = Directory.new
        @attributes = Directory.new
        @builtin_types = Directory.new
        @soap_encoding_types = Directory.new
        @qualified_elements = false
        @qualified_attributes = false
        @imports = []
        @unresolved_imports = []
      end

      def add_import(ns, schema)
        @imports << schema
      end

      def add_type(type)
        if type.name
          @types[type.name] = type
        else
          @anon_types << type
        end
        type
      end

      def add_element(element)
        @elements[element.name] = element
      end

      def add_attribute(attr)
        @attributes[attr.name] = attr
      end

      def get_type(name)
        return if name.nil?

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

      def get_element(name)
        @elements[name] || @imports.lazy.map { |s| s.get_element(name) }.reject(&:nil?).first
      end

      def get_attribute(name)
        @attributes[name] || @imports.lazy.map { |s| s.get_attribute(name) }.reject(&:nil?).first
      end

      def each_type(&block)
        enum = Enumerator.new do |y|
          @types.each do |(n, t)|
            y << t
          end
          @anon_types.each do |t|
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

      def each_element(&block)
        recursive_each @elements, :each_element, &block
      end

      def each_attribute(&block)
        recursive_each @attributes, :each_attribute, &block
      end

      def each_builtin_type(&block)
        @builtin_types.values.each(&block)
      end

      def each_soap_encoding_type(&block)
        @soap_encoding_types.values.each(&block)
      end

      protected
      def recursive_each(array, accessor, &block)
        enum = Enumerator.new do |y|
          array.each do |(n, t)|
            y << t
          end
          @imports.each do |i|
            i.send(accessor) do |t|
              y << t
            end
          end
        end

        block_given? ? enum.each(&block) : enum
      end
    end
  end
end
