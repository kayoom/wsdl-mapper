require 'wsdl_mapper/dom_generation/default_wrapping_type_generator'
require 'wsdl_mapper/dom_generation/yard_doc_formatter'

module WsdlMapper
  module DomGeneration
    class DocumentedWrappingTypeGenerator < DefaultWrappingTypeGenerator

      protected
      def open_class f, ttg
        yard = YardDocFormatter.new f
        yard.class_doc ttg.type
        f.begin_class ttg.name.class_name
      end
    end
  end
end
