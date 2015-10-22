require 'wsdl_mapper/dom/builtin_type'
require 'wsdl_mapper/type_mapping/mapping_set'

module WsdlMapper
  module TypeMapping
    class Base
      attr_accessor :ruby_types, :xml_types

      def initialize &block
        instance_exec &block
        self.class.mapping_set << self
      end

      def register_xml_types names
        self.xml_types ||= []
        names.each do |name_or_qname|
          qname = name_or_qname.is_a?(WsdlMapper::Dom::Name) ? name_or_qname : WsdlMapper::Dom::BuiltinType[name_or_qname].name
          self.xml_types << qname
        end
      end

      def maps? t
        if t.is_a?(WsdlMapper::Dom::Name)
          xml_types.include? t
        elsif t.is_a?(WsdlMapper::Dom::TypeBase)
          xml_types.include? t.name
        end
      end

      def to_ruby string
        raise NotImplementedError
      end

      def to_xml object
        raise NotImplementedError
      end

      def self.mapping_set
        @mapping_set ||= MappingSet.new
      end

      def self.get_mapping type
        @mapping_set.find type
      end
    end
  end
end
