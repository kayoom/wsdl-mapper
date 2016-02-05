module WsdlMapper
  module Deserializers
    module Errors
      class UnknownError < StandardError
        attr_reader :name
        attr_accessor :parent

        def initialize(name)
          @name = name
          super "Unknown: #{name}"
        end

        def to_s
          "Unknown: #{name} in #{parent}"
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
