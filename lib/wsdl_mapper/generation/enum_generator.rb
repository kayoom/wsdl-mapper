module WsdlMapper
  module Generation
    class EnumGenerator
      def initialize generator
        @generator = generator
      end

      def generate type, result
        file_name = @generator.context.path_for type.name

        modules = type.name.parents.reverse

        File.open file_name, 'w' do |io|
          f = @generator.get_formatter io

          modules.each do |mod|
            f.begin_module mod.module_name
          end
          f.begin_sub_class type.name.class_name, '::String'
          values_to_generate = type.type.enumeration_values.map do |ev|
            name = @generator.namer.get_enumeration_value_name ev
            TypeToGenerate.new ev, name
          end

          values_to_generate.each do |vtg|
            f.statement "#{vtg.name.constant_name} = new(#{vtg.type.value.inspect}).freeze"
          end
          f.next_statement
          f.literal_array values_to_generate.map { |vtg| vtg.name.constant_name }
          f.end
          modules.each { f.end }
        end
        result.files << file_name
        self
      end
    end
  end
end
