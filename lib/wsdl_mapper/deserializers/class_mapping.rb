require 'wsdl_mapper/dom/directory'
require 'wsdl_mapper/dom/name'
require 'wsdl_mapper/dom/builtin_type'
require 'wsdl_mapper/deserializers/attr_mapping'
require 'wsdl_mapper/deserializers/prop_mapping'
require 'wsdl_mapper/deserializers/errors'

module WsdlMapper
  module Deserializers
    class ClassMapping
      class Delegate < Struct.new(:accessor, :type_name)
      end

      include ::WsdlMapper::Dom
      attr_reader :attributes, :properties

      def initialize(cls, simple: false, &block)
        @cls = cls
        @attributes = Directory.new on_nil: Errors::UnknownAttributeError
        @properties = Directory.new on_nil: Errors::UnknownElementError
        @simple = simple
        @wrappers = Directory.new
        instance_exec &block
      end

      def register_attr(accessor, attr_name, type_name)
        attr_name = Name.get *attr_name
        @attributes[attr_name] = AttrMapping.new(accessor, attr_name, Name.get(*type_name))
      end

      def register_prop(accessor, prop_name, type_name, array: false)
        prop_name = Name.get *prop_name
        @properties[prop_name] = PropMapping.new(accessor, prop_name, Name.get(*type_name), array: array)
      end

      def register_delegate(accessor, type_name)
        @delegate = Delegate.new accessor, Name.get(*type_name)
      end

      def register_wrapper(name)
        name = Name.get *name
        @wrappers[name] = true
      end

      def wrapper?(name)
        @wrappers[name]
      end

      def start(base, frame)
        # frame.object = @simple ? @cls.new(nil) : @cls.new
      end

      def end(base, frame)
        frame.object = build_object base, frame

        if @delegate
          mapping = base.get_type_mapping @delegate.type_name
          delegate = mapping.build_object base, frame
          mapping.set_properties base, frame, delegate
          mapping.set_attributes base, frame, delegate
          frame.object.send "#{@delegate.accessor}=", delegate
        else
          set_attributes base, frame, frame.object
          set_properties base, frame, frame.object
        end
      end

      def build_object(base, frame)
        if @simple
          type_name = WsdlMapper::Dom::Name.get *@simple
          content = base.to_ruby type_name, frame.text
          @cls.new content
        else
          @cls.new
        end
      end

      def get_type_name_for_prop(prop_name)
        @properties[prop_name].type_name
      end

      def set_properties(base, frame, object)
        frame.children.each do |child|
          name = child.name
          prop_mapping = properties[name]

          if BuiltinType.builtin? prop_mapping.type_name
            ruby_value = base.to_ruby prop_mapping.type_name, child.text
            prop_mapping.set object, ruby_value
          else
            prop_mapping.set object, child.object
          end
        end
      end

      def set_attributes(base, frame, object)
        frame.attrs.each do |(name, value)|
          attr_mapping = attributes[name]
          ruby_value = base.to_ruby attr_mapping.type_name, value
          attr_mapping.set object, ruby_value
        end
      end
    end
  end
end
