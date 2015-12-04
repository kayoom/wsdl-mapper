module WsdlMapper
  module Naming
    class EnumerationValueName
      attr_reader :constant_name, :key_name

      def initialize(constant_name, key_name)
        @constant_name = constant_name
        @key_name = key_name
      end
    end
  end
end
