require 'wsdl_mapper/dom/builtin_type'

module WsdlMapper
  module TypeMapping
    class Base
      attr_accessor :ruby_types, :xml_types

      def initialize &block
        instance_exec &block
        self.class.type_mappings << self
      end

      def register_ruby_types types
        self.ruby_types ||= []
        self.ruby_types.concat(types).uniq!
      end

      def register_xml_types types
        self.xml_types ||= []
        types.each do |type|
          if type.is_a?(WsdlMapper::Dom::Name)
            self.xml_types << type
          else
            self.xml_types << WsdlMapper::Dom::BuiltinType[type].name
          end
        end
      end

      # TODO: maybe maps?(Ruby Type) is never needed
      def maps? t
        if t.is_a?(WsdlMapper::Dom::Name)
          xml_types.include? t
        elsif t.is_a?(WsdlMapper::Dom::TypeBase)
          xml_types.include? t.name
        elsif t.is_a?(Class)
          ruby_types.any? { |rt| t <= rt }
        else
          ruby_types.any? { |rt| rt === t }
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
