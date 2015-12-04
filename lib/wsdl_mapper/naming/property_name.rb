module WsdlMapper
  module Naming
    class PropertyName
      attr_reader :attr_name, :var_name

      def initialize(attr_name, var_name)
        @attr_name = attr_name
        @var_name = var_name
      end
    end
  end
end
