require 'nokogiri'

require 'wsdl_mapper/naming/default_namer'
require 'wsdl_mapper/generation/context'
require 'wsdl_mapper/generation/schema_generator'
require 'wsdl_mapper/generation/default_ctr_generator'
require 'wsdl_mapper/schema/parser'
require 'wsdl_mapper/generation/documented_class_generator'
require 'wsdl_mapper/generation/default_class_generator'

module WsdlMapper
  module Generation
    class Facade
      def initialize(file:, out:, module_path:, docs: false)
        @file = file
        @out = out
        @module_path = module_path
        @docs = docs
      end

      def generate
        context = Context.new @out
        namer = WsdlMapper::Naming::DefaultNamer.new module_path: @module_path
        class_generator = @docs ? DocumentedClassGenerator : DefaultClassGenerator

        generator = SchemaGenerator.new context,
          namer: namer,
          ctr_generator_factory: DefaultCtrGenerator,
          class_generator_factory: class_generator

        file_content = File.read @file
        xml_doc = Nokogiri::XML::Document.parse file_content
        parser = WsdlMapper::Schema::Parser.new
        schema = parser.parse xml_doc

        generator.generate schema
      end
    end
  end
end
