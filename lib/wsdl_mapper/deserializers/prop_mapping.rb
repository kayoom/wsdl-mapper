require 'wsdl_mapper/deserializers/attr_mapping'

module WsdlMapper
  module Deserializers
    class PropMapping < AttrMapping
      def initialize *args, array: false
        super(*args)
        @array = array
      end

      def array?
        !!@array
      end

      def set obj, value
        if array?
          obj.send setter, obj.send(getter) || []
          obj.send(getter) << value
        else
          super
        end
      end
    end
  end
end

