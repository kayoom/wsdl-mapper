module WsdlMapper
  module Naming
    # Represents a name of a ruby property, consisting of its instance
    # variable and its accessors (attribute).
    class PropertyName
      attr_reader :attr_name, :var_name

      # @param [String] attr_name Name for the attribute accessors
      # @param [String] var_name Name for the instance variable
      def initialize(attr_name, var_name)
        @attr_name = attr_name
        @var_name = var_name
      end
    end
  end
end
