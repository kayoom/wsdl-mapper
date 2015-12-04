module WsdlMapper
  module Serializers
    # @abstract
    class AbstractResolver
      def resolve(name)
        raise NotImplementedError
      end
    end
  end
end
