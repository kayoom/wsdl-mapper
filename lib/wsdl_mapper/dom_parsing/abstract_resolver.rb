module WsdlMapper
  module DomParsing
    # @abstract
    class AbstractResolver
      def resolve name
        raise NotImplementedError
      end
    end
  end
end
