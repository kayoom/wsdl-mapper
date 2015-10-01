require 'wsdl_mapper/dom/bounds'

module WsdlMapper
  module Dom
    class Attribute
      attr_reader :name, :type_name, :default, :use, :fixed, :form
      attr_accessor :documentation

      def initialize name, type_name, default: nil, use: nil, fixed: nil, form: nil
        @name, @type_name = name, type_name
        @documentation = Documentation.new
        @default = default
        @use = use
        @fixed = fixed
        @form = form
      end
    end
  end
end
