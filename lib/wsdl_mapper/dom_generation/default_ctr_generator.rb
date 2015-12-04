require 'wsdl_mapper/dom/builtin_type'

module WsdlMapper
  module DomGeneration
    class DefaultCtrGenerator
      def initialize(generator)
        @generator = generator
      end

      def generate(ttg, f, result)
        props = ttg.type.each_property.to_a
        attrs = ttg.type.each_attribute.to_a

        base_props, base_attrs = get_base_props(ttg.type), get_base_attrs(ttg.type)

        f.in_def 'initialize', *get_prop_kw_args((props + base_props).uniq(&:name)), *get_attr_kw_args((attrs + base_attrs).uniq(&:name)) do
          if ttg.type.base
            f.call :super, *get_prop_kw_assigns(base_props), *get_attr_kw_assigns(base_attrs)
          end
          f.assignments *get_prop_assigns(props)
          f.assignments *get_attr_assigns(attrs)
        end
      end

      def generate_simple(ttg, f, result)
        attrs = ttg.type.each_attribute
        content_name = @generator.namer.get_content_name ttg.type

        f.in_def 'initialize', content_name.attr_name, *get_attr_kw_args(attrs) do
          f.assignments [content_name.var_name, content_name.attr_name]
          f.assignments *get_attr_assigns(attrs)
        end
      end

      def generate_wrapping(ttg, f, result, var_name, par_name)
        f.in_def 'initialize', par_name do
          f.assignment var_name, par_name
        end
      end

      protected
      def get_base_attrs(type)
        return [] unless type.base
        type.base.each_attribute.to_a + get_base_attrs(type.base)
      end

      def get_base_props(type)
        return [] unless type.base
        type.base.each_property.to_a + get_base_props(type.base)
      end

      def get_prop_kw_assigns(props)
        props.map do |p|
          name = @generator.namer.get_property_name p
          "#{name.attr_name}: #{name.attr_name}"
        end
      end

      def get_attr_kw_assigns(attrs)
        attrs.map do |a|
          name = @generator.namer.get_attribute_name a
          "#{name.attr_name}: #{name.attr_name}"
        end
      end

      def get_prop_kw_args(props)
        props.map do |p|
          name = @generator.namer.get_property_name p
          default = @generator.value_defaults_generator.generate_for_property p
          "#{name.attr_name}: #{default}"
        end
      end

      def get_attr_kw_args(attrs)
        attrs.map do |a|
          name = @generator.namer.get_attribute_name a
          default = @generator.value_defaults_generator.generate_for_attribute a
          "#{name.attr_name}: #{default}"
        end
      end

      def get_prop_assigns(props)
        props.map do |p|
          name = @generator.namer.get_property_name p
          [name.var_name, name.attr_name]
        end
      end

      def get_attr_assigns(attrs)
        attrs.map do |a|
          name = @generator.namer.get_attribute_name a
          [name.var_name, name.attr_name]
        end
      end
    end
  end
end
