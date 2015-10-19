module WsdlMapper
  module Generation
    class ClassGenerator
      def initialize generator
        @generator = generator
      end

      def generate ttg, result
        file_name = @generator.context.path_for ttg.name
        property_names = ttg.type.each_property.map { |p| @generator.namer.get_property_name p }
        modules = ttg.name.parents.reverse

        File.open file_name, 'w' do |io|
          f = @generator.get_formatter io

          modules.each do |mod|
            f.begin_module mod.module_name
          end
          f.begin_class ttg.name.class_name
          f.attr_accessor *property_names.map(&:attr_name)
          f.end
          modules.each { f.end }
        end
        result.files << file_name
        self
      end
    end
  end
end
