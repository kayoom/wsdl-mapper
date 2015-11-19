require 'wsdl_mapper/generation/facade'
require 'wsdl_mapper/s8r_generation/s8r_generator'

module WsdlMapper
  module S8rGeneration
    class Facade < WsdlMapper::Generation::Facade
      def generator_class
        WsdlMapper::S8rGeneration::S8rGenerator
      end
    end
  end
end
