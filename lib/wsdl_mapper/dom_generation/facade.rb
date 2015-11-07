require 'nokogiri'

require 'wsdl_mapper/naming/default_namer'
require 'wsdl_mapper/generation/context'
require 'wsdl_mapper/dom_generation/schema_generator'
require 'wsdl_mapper/dom_generation/documented_schema_generator'
require 'wsdl_mapper/schema/parser'

module WsdlMapper
  module DomGeneration
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
        generator_class = @docs ? DocumentedSchemaGenerator : SchemaGenerator

        generator = generator_class.new context,
          namer: namer

        file_content = File.read @file
        xml_doc = Nokogiri::XML::Document.parse file_content
        parser = WsdlMapper::Schema::Parser.new
        schema = parser.parse xml_doc

        generator.generate schema
      end
    end
  end
end
