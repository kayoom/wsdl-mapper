require 'wsdl_mapper/dom/bounds'
require 'wsdl_mapper/dom/type_base'

module WsdlMapper
  module Dom
    class Attribute
      class Ref < TypeBase
        attr_accessor :containing_type
      end

      attr_reader :name, :type_name, :default, :use, :fixed, :form
      attr_accessor :type
      attr_accessor :documentation
      attr_accessor :containing_type

      def initialize(name, type_name, default: nil, use: nil, fixed: nil, form: nil)
        @name, @type_name = name, type_name
        @documentation = Documentation.new
        @default = default
        @use = use
        @fixed = fixed
        @form = form
      end

      def default?
        !!@default
      end

      def fixed?
        !!@fixed
      end

      def optional?
        @use == 'optional'
      end

      def required?
        @use == 'required'
      end
    end
  end
end
