require 'wsdl_mapper/dom/directory'
require 'wsdl_mapper/dom/name'
require 'wsdl_mapper/dom/builtin_type'
require 'wsdl_mapper/deserializers/attr_mapping'
require 'wsdl_mapper/deserializers/prop_mapping'
require 'wsdl_mapper/deserializers/errors'

module WsdlMapper
  module Deserializers
    class ClassMapping
      include ::WsdlMapper::Dom
      attr_reader :attributes, :properties

      def initialize cls, simple: false, &block
        @cls = cls
        @attributes = Directory.new on_nil: Errors::UnknownAttributeError
        @properties = Directory.new on_nil: Errors::UnknownElementError
        instance_exec &block
        @simple = simple
      end

      def register_attr accessor, attr_name, type_name
        attr_name = Name.get *attr_name
        @attributes[attr_name] = AttrMapping.new(accessor, attr_name, Name.get(*type_name))
      end

      def register_prop accessor, prop_name, type_name, array: false
        prop_name = Name.get *prop_name
        @properties[prop_name] = PropMapping.new(accessor, prop_name, Name.get(*type_name), array: array)
      end

      def start base, frame
        frame.object = @simple ? @cls.new(nil) : @cls.new
      end

      def end base, frame
        if @simple
          type_name = WsdlMapper::Dom::Name.get *@simple
          content = base.to_ruby type_name, frame.text
          frame.object = @cls.new content
        else
          frame.object = @cls.new
        end
        set_attributes base, frame
        set_properties base, frame
      end

      def get_type_name_for_prop prop_name
        @properties[prop_name].type_name
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
