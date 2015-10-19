require 'wsdl_mapper/dom/builtin_type'
require 'bigdecimal'

module WsdlMapper
  module Generation
    class SimpleCtrGenerator
      def initialize generator
        @generator = generator
        @builtin_types = WsdlMapper::Dom::BuiltinType
      end

      def generate ttg, f, result
        props = ttg.type.each_property
        kw_args = props.map do |p|
          name = @generator.namer.get_property_name p
          "#{name.attr_name}: nil"
        end

        f.begin_def 'initialize', kw_args
        props.each do |p|
          name = @generator.namer.get_property_name p
          f.statement "#{name.var_name} = #{name.attr_name}"
        end
        f.end
      end
    end
  end
end
