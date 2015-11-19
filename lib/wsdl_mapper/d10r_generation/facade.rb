require 'wsdl_mapper/generation/facade'
require 'wsdl_mapper/d10r_generation/d10r_generator'

module WsdlMapper
  module D10rGeneration
    class Facade < WsdlMapper::Generation::Facade
      def generator_class
        WsdlMapper::D10rGeneration::D10rGenerator
      end
    end
  end
end
