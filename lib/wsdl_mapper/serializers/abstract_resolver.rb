module WsdlMapper
  module Serializers
    # @abstract
    # noinspection RubyUnusedLocalVariable
    class AbstractResolver
      def resolve(name)
        raise NotImplementedError
      end
    end
  end
end
