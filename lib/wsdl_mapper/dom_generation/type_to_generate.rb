module WsdlMapper
  module DomGeneration
    class TypeToGenerate
      attr_reader :type, :name

      def initialize type, type_name
        @type = type
        @name = type_name
      end
    end
  end
end
