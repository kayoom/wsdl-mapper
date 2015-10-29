require 'wsdl_mapper/generation/default_enum_generator'
require 'wsdl_mapper/generation/yard_doc_formatter'

module WsdlMapper
  module Generation
    class DocumentedEnumGenerator < DefaultEnumGenerator

      # def generate ttg, result
      #   file_name = @generator.context.path_for ttg.name
      #
      #   modules = ttg.name.parents.reverse
      #
      #   File.open file_name, 'w' do |io|
      #     f = @generator.get_formatter io
      #     values_to_generate = get_values_to_generate(ttg)
      #
      #     open_modules f, modules
      #     open_class f, ttg
      #     generate_constant_assignments f, values_to_generate
      #     generate_values_array f, values_to_generate
      #     close_class f, ttg
      #     close_modules f, modules
      #   end
      #   result.files << file_name
      #   self
      # end

      protected
      def generate_constant_assignments f, values_to_generate
        yard = YardDocFormatter.new f
        values_to_generate.each do |vtg|
          if vtg.type.documentation.present?
            yard.text vtg.type.documentation.default
            yard.blank_line
          end
          yard.tag 'xml_value', vtg.type.value
          f.statement value_constant_assignment vtg
          f.blank_line
        end
        f.after_constants
      end

      def open_class f, ttg
        yard = YardDocFormatter.new f
        yard.class_doc ttg.type
        super
      end
    end
  end
end
