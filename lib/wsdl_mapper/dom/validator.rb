require 'wsdl_mapper/dom/simple_type'
require 'wsdl_mapper/dom/builtin_type'

module WsdlMapper
  module Dom
    class Validator
      class Error
        attr_reader :element, :msg

        def initialize(element, msg)
          @element = element
          @msg = msg
        end
      end

      def initialize(schema)
        @schema = schema
      end

      def validate
        @errors = []
        validate_roots
        @errors
      end

      def validate_roots
        @schema.each_type do |type|
          next unless type.is_a?(::WsdlMapper::Dom::SimpleType)
          next if type.root.is_a?(::WsdlMapper::Dom::BuiltinType)

          @errors << Error.new(type, :invalid_root)
        end
      end
    end
  end
end
