require 'wsdl_mapper/dom_generation/default_wrapping_type_generator'
require 'wsdl_mapper/generation/yard_doc_formatter'

module WsdlMapper
  module DomGeneration
    class DocumentedWrappingTypeGenerator < DefaultWrappingTypeGenerator

      protected
      def in_class f, ttg
        yard = WsdlMapper::Generation::YardDocFormatter.new f
        yard.class_doc ttg.type

        super
      end
    end
  end
end
