require 'wsdl_mapper/dom/directory'
require 'wsdl_mapper/dom/name'
require 'wsdl_mapper/dom/builtin_type'

module WsdlMapper
  module Deserializers
    class SoapArrayMapping
      include ::WsdlMapper::Dom

      def initialize(cls, type:)
        @cls = cls
        @type = Name.get *type
      end

      def start(base, frame)
        frame.object = @cls.new
      end

      def end(base, frame)
        frame.children.each do |child|
          frame.object << child.object
        end
      end

      def get_type_name_for_prop(element_name)
        @type
      end

      def wrapper?(name)
        false
      end
    end
  end
end
