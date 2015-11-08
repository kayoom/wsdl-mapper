require 'test_helper'

require 'wsdl_mapper/schema/parser'
require 'wsdl_mapper/generation/context'
require 'wsdl_mapper/d10r_generation/d10r_generator'

module D10rGenerationTests
  class D10rGeneratorTests < GenerationTestCase
    def generate name
      schema = get_schema name
      generator = WsdlMapper::D10rGeneration::D10rGenerator.new context
      generator.generate schema
    end

    def test_basic_empty_type
      generate 'empty_note_type.xsd'

      assert_file_is "deserializer_factory.rb", <<RUBY
require "wsdl_mapper/deserializers/deserializer_factory"

DeserializerFactory = ::WsdlMapper::Deserializers::DeserializerFactory.new

RUBY

      assert_file_is "note_type_deserializer.rb", <<RUBY
require "deserializer_factory"
require "note_type"

NoteTypeDeserializer = ::DeserializerFactory.register(nil, "noteType", ::NoteType) do
end
RUBY
    end
  end
end
