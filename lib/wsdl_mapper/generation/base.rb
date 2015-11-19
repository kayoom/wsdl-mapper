module WsdlMapper
  module Generation
    # @abstract
    class Base
      protected
      def generate_name name
        return 'nil' if name.nil?

        ns = name.ns.inspect
        local_name = name.name.inspect

        "[#{ns}, #{local_name}]"
      end

      def get_type_name type
        if type.name
          type
        elsif type.containing_element
          @namer.get_inline_type type.containing_element
        elsif type.containing_property
          @namer.get_inline_type type.containing_property
        end
      end
    end
  end
end
