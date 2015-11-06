module WsdlMapper
  module Schema
    # @abstract
    class AbstractResolver
      def resolve name
        raise NotImplementedError
      end
    end
  end
end
