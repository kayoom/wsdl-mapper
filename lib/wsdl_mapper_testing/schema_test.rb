require 'wsdl_mapper_testing/test'

module WsdlMapperTesting
  class SchemaTest < Test
    def get_schema name
      TestHelper.parse_schema name
    end
  end
end
