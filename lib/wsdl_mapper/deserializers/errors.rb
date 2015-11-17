module WsdlMapper
  module Deserializers
    module Errors
      class UnknownError < StandardError
        attr_reader :name

        def initialize name
          @name = name
          super "Unknown: #{name}"
        end
      end

      class UnknownElementError < UnknownError
      end

      class UnknownAttributeError < UnknownError
      end

      class UnknownTypeError < UnknownError
      end
    end
  end
end
