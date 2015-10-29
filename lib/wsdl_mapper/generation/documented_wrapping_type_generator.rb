require 'wsdl_mapper/generation/default_wrapping_type_generator'

module WsdlMapper
  module Generation
    class DocumentedWrappingTypeGenerator < DefaultWrappingTypeGenerator

      protected
      def get_requires type, schema
        requires = []
        add_base_require requires, type, schema
        # TODO: collect requires from ctr generator
        requires.uniq
      end

      def open_class f, ttg
        yard = YardDocFormatter.new f
        yard.class_doc ttg.type
        f.begin_class ttg.name.class_name
      end

      def close_class f, ttg
        f.end
      end

      def generate_ctr f, ttg, result
        @generator.ctr_generator.generate_wrapping ttg, f, result, '@value', 'value'
      end

      def generate_accessor f, ttg
        f.attr_accessor 'value'
      end
    end
  end
end
