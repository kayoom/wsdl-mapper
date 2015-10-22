require 'wsdl_mapper/dom/builtin_type'

module WsdlMapper
  module TypeMapping
    class Base
      attr_accessor :ruby_types, :xml_types

      def initialize &block
        instance_exec &block
        self.class.type_mappings << self
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

      def self.type_mappings
        @type_mappings ||= []
      end

      def self.get_mapping type
        @type_mappings.find { |tm| tm.maps? type }
      end
    end
  end
end
