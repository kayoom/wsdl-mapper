require 'wsdl_mapper/dom/builtin_type'

module WsdlMapper
  module Generation
    class DefaultCtrGenerator
      def initialize generator
        @generator = generator
      end

      def generate ttg, f, result
        props = ttg.type.each_property
        attrs = ttg.type.each_attribute

        f.begin_def 'initialize', get_prop_kw_args(props) + get_attr_kw_args(attrs)
        f.assignment *get_prop_assigns(props)
        f.assignment *get_attr_assigns(attrs)
        f.end
      end

      def generate_wrapping ttg, f, result, var_name, par_name
        f.begin_def "initialize", [par_name]
        f.assignment [var_name, par_name]
        f.end
      end

      protected
      def get_prop_kw_args props
        props.map do |p|
          name = @generator.namer.get_property_name p
          default = @generator.value_defaults_generator.generate_for_property p
          "#{name.attr_name}: #{default}"
        end
      end

      def get_attr_kw_args attrs
        attrs.map do |a|
          name = @generator.namer.get_attribute_name a
          default = @generator.value_defaults_generator.generate_for_attribute a
          "#{name.attr_name}: #{default}"
        end
      end

      def get_prop_assigns props
        props.map do |p|
          name = @generator.namer.get_property_name p
          [name.var_name, name.attr_name]
        end
      end

      def get_attr_assigns attrs
        attrs.map do |a|
          name = @generator.namer.get_attribute_name a
          [name.var_name, name.attr_name]
        end
      end
    end
  end
end
