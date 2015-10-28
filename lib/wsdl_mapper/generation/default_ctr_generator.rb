require 'wsdl_mapper/dom/builtin_type'
require 'bigdecimal'

module WsdlMapper
  module Generation
    class DefaultCtrGenerator
      def initialize generator
        @generator = generator
        @builtin_types = WsdlMapper::Dom::BuiltinType
      end

      def generate ttg, f, result
        props = ttg.type.each_property

        f.begin_def 'initialize', get_kw_args(props)
        f.assignment *get_assigns(props)
        f.end
      end

      def generate_wrapping ttg, f, result, var_name, par_name
        f.begin_def "initialize", [par_name]
        f.assignment [var_name, par_name]
        f.end
      end

      protected
      def get_kw_args props
        props.map do |p|
          name = @generator.namer.get_property_name p
          default = @generator.ctr_defaults_generator.generate p
          "#{name.attr_name}: #{default}"
        end
      end

      def get_assigns props
        props.map do |p|
          name = @generator.namer.get_property_name p
          [name.var_name, name.attr_name]
        end
      end
    end
  end
end
