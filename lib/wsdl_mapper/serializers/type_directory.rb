require 'wsdl_mapper/dom/name'

module WsdlMapper
  module Serializers
    class TypeDirectory
      class TypeItem < Struct.new(:type_name, :require_path, :s8r_name)
      end

      def initialize &block
        @types = {}
        @elements = {}
        @serializers = {}
        @by_type_name = Hash.new do |h, k|
          h[k] = find_and_load k
        end
        instance_exec &block
      end

      def register_element name, element_name
        @elements[normalize(name)] = WsdlMapper::Dom::Name.get *element_name
      end

      def register_type type_name, require_path, s8r_name
        item = TypeItem.new type_name, require_path, s8r_name
        @types[normalize(type_name)] = item
      end

      def get_element_name name
        @elements[normalize(name)]
      end

      def resolve name
        @by_type_name[normalize(name)]
      end

      def register_serializer s8r_name, serializer
        @serializers[normalize(s8r_name)] = serializer
      end

      def find obj
        resolve obj.class.name
      end

      protected
      def find_and_load type_name
        item = @types[type_name]
        unless item
          raise StandardError.new "Serializer for #{type_name} not found."
        end
        require item.require_path
        @serializers[normalize(item.s8r_name)]
      end

      def normalize name
        name[0, 2] == '::' ? name : '::' + name
      end
    end
  end
end
