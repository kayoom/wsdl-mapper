require 'wsdl_mapper/generation/default_formatter'
require 'wsdl_mapper/naming/default_namer'
require 'wsdl_mapper/generation/result'

require 'wsdl_mapper/generation/type_generator'

require 'wsdl_mapper/dom/complex_type'

module WsdlMapper
  module Generation
    class Generator
      def initialize context, formatter_class: DefaultFormatter, namer_class: WsdlMapper::Naming::DefaultNamer
        @formatter_class = formatter_class
        @context = context
        @namer_class = namer_class
      end

      def generate schema
        result = Result.new

        complex_types = schema.each_type.select(&WsdlMapper::Dom::ComplexType).to_a

        to_generate = complex_types.map do |type|
          name =
        end

        result
      end
    end
  end
end
