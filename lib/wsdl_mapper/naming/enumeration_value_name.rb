module WsdlMapper
  module Naming
    # Represents the value of an enumeration value, consisting of the constant to
    # generate and the string key, that will be the enumeration value.
    class EnumerationValueName
      attr_reader :constant_name, :key_name

      # @param [String] constant_name Name for the constant to generate.
      # @param [String] key_name String value.
      def initialize(constant_name, key_name)
        @constant_name = constant_name
        @key_name = key_name
      end
    end
  end
end
