require 'test_helper'

require 'wsdl_mapper/dom/name'
require 'wsdl_mapper_testing/implementation_test'
require 'wsdl_mapper/naming/abstract_service_namer'
require 'wsdl_mapper/naming/default_service_namer'

module NamingTests
  class DefaultServiceNamerTest < WsdlMapperTesting::ImplementationTest

    def test_implementation
      assert_implements WsdlMapper::Naming::AbstractServiceNamer, WsdlMapper::Naming::DefaultServiceNamer
    end
  end
end
