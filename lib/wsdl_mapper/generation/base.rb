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
    end
  end
end
