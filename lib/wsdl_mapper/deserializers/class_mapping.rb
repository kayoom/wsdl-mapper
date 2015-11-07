require 'wsdl_mapper/dom/directory'
require 'wsdl_mapper/dom/name'
require 'wsdl_mapper/dom/builtin_type'
require 'wsdl_mapper/deserializers/attr_mapping'
require 'wsdl_mapper/deserializers/prop_mapping'

module WsdlMapper
  module Deserializers
    class ClassMapping
      include ::WsdlMapper::Dom
      attr_reader :attributes, :properties

      def initialize cls, &block
        @cls = cls
        @attributes = Directory.new
        @properties = Directory.new
        instance_exec &block
      end

      def register_attr accessor, attr_name, type_name
        @attributes[attr_name] = AttrMapping.new(accessor, attr_name, type_name)
      end

      def register_prop accessor, prop_name, type_name, array: false
        @properties[prop_name] = PropMapping.new(accessor, prop_name, type_name, array: array)
      end

      def start base, frame
        frame.object = @cls.new
        set_attributes base, frame
      end

      def end base, frame
        set_properties base, frame
      end

      def get_type prop_name
        @properties[prop_name].type_name
      rescue NoMethodError
        raise ArgumentError.new("Property #{prop_name} not found in #{@cls} mapping.")
      end

      protected
      def set_properties base, frame
        frame.children.each do |child|
          name = child.name
          prop_mapping = properties[name]

          if BuiltinType.builtin? prop_mapping.type_name
            ruby_value = base.to_ruby prop_mapping.type_name, child.text
            prop_mapping.set frame.object, ruby_value
          else
            prop_mapping.set frame.object, child.object
          end
        end
      end

      def set_attributes base, frame
        frame.attrs.each do |(name, value)|
          attr_mapping = attributes[name]
          ruby_value = base.to_ruby attr_mapping.type_name, value
          attr_mapping.set frame.object, ruby_value
        end
      end
    end
  end
end
