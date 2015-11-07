module WsdlMapper
  module Deserializers
    class AttrMapping < Struct.new(:accessor, :name, :type_name)
      def getter
        accessor
      end

      def setter
        "#{accessor}="
      end

      def get obj
        obj.send getter
      end

      def set obj, value
        obj.send setter, value
      end
    end
  end
end
