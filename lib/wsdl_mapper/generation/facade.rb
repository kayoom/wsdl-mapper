require 'nokogiri'

require 'wsdl_mapper/naming/default_namer'
require 'wsdl_mapper/naming/separating_namer'
require 'wsdl_mapper/generation/context'
require 'wsdl_mapper/dom_parsing/parser'

module WsdlMapper
  module Generation
    # @abstract
    class Facade
      # @param [String] file Full path to the XSD or WSDL file
      # @param [String] out Full path to the desired output directory
      # @param [Array<String>] module_path Array of module names, to use as root module, i.e. `['Foo', 'Bar']` for `Foo::Bar`
      # @param [true, false] docs Set to `true` to generate documentation
      # @param [true, false] separate_modules Set to `true` to separate types and (de)serializers into different modules
      # @param [WsdlMapper::Naming::AbstractNamer] namer Inject a namer instance here to be used
      def initialize(file:, out:, module_path: [], docs: false, separate_modules: true, namer: nil)
        @file = file
        @out = out
        @module_path = module_path
        @docs = docs
        @separate_modules = separate_modules
        @namer = namer
      end

      def generate
        generator.generate parser.parse document
      end

      protected
      def context
        @context ||= WsdlMapper::Generation::Context.new @out
      end

      def namer
        @namer ||= @separate_modules ?
          WsdlMapper::Naming::SeparatingNamer.new(module_path: @module_path) :
          WsdlMapper::Naming::DefaultNamer.new(module_path: @module_path)
      end

      def generator_class
        raise NotImplementedError
      end

      def generator
        @generator ||= generator_class.new context, namer: namer
      end

      def document
        @document ||= Nokogiri::XML::Document.parse File.read @file
      end

      def parser
        @parser ||= WsdlMapper::DomParsing::Parser.new
      end
    end
  end
end
