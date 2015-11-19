require 'thor'

require 'wsdl_mapper/dom_generation/facade'
require 'wsdl_mapper/s8r_generation/facade'
require 'wsdl_mapper/d10r_generation/facade'

module WsdlMapper
  module Cli
    class Generate < Thor
      class_option :out
      class_option :module
      class_option :separate_modules, type: :boolean, default: true
      class_option :clear, type: :boolean
      class_option :docs, type: :boolean

      no_tasks do
        def facade_options xsd_file
          {
            file: xsd_file,
            out: out(xsd_file),
            module_path: module_path,
            docs: options[:docs],
            separate_modules: options[:separate_modules]
          }
        end

        def module_path
          options[:module] ? options[:module].split('::').compact : []
        end

        def out xsd_file
          options[:out] || File.join(FileUtils.pwd, file_name(xsd_file))
        end

        def file_name xsd_file
          File.basename xsd_file, '.xsd'
        end
      end

      desc 'dom <xsd_file>', 'Generates classes for the schema in <xsd_file>'
      def dom xsd_file
        generator = WsdlMapper::DomGeneration::Facade.new **facade_options(xsd_file)
        FileUtils.rmtree out(xsd_file) if options[:clear]
        generator.generate
      end

      desc 's8r <xsd_file>', 'Generate serializers for the schema in <xsd_file>'
      def s8r xsd_file
        generator = WsdlMapper::S8rGeneration::Facade.new **facade_options(xsd_file)
        FileUtils.rmtree out(xsd_file) if options[:clear]
        generator.generate
      end

      desc 'd10r <xsd_file>', 'Generate deserializers for the schema in <xsd_file>'
      def d10r xsd_file
        generator = WsdlMapper::D10rGeneration::Facade.new **facade_options(xsd_file)
        FileUtils.rmtree out(xsd_file) if options[:clear]
        generator.generate
      end

      desc 'all <xsd_file>', 'Generate DOM, Serializers, Deserializers for the schema in <xsd_file>'
      def all xsd_file
        file_name = File.basename xsd_file, '.xsd'
        out = options[:out] || File.join(FileUtils.pwd, file_name)
        FileUtils.rmtree out if options[:clear]

        invoke :dom, [xsd_file], options.merge(clear: false)
        invoke :s8r, [xsd_file], options.merge(clear: false)
        invoke :d10r, [xsd_file], options.merge(clear: false)
      end
    end

    class Cli < Thor
      desc 'generate SUBCOMMAND ...ARGS', 'Generate DOM and/or (De)Serializers'
      subcommand 'generate', Generate
    end
  end
end
