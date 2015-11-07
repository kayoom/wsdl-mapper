require 'test_helper'

require 'wsdl_mapper/schema/parser'
require 'wsdl_mapper/generation/context'
require 'wsdl_mapper/d10r_generation/d10r_generator'

module D10rGenerationTests
  class D10rGeneratorTests < ::Minitest::Test
    def setup
      @tmp_path = TestHelper.get_tmp_path
    end

    def teardown
      @tmp_path.unlink
    end

    def test_basic_empty_type
      schema = TestHelper.parse_schema 'empty_note_type.xsd'
      context = WsdlMapper::Generation::Context.new @tmp_path.to_s
      generator = WsdlMapper::D10rGeneration::D10rGenerator.new context

      result = generator.generate schema

      expected_file = @tmp_path.join("deserializer_factory.rb")
      assert File.exists? expected_file

      generated_class = File.read expected_file
      assert_equal <<RUBY, generated_class
require "wsdl_mapper/deserializers/deserializer_factory"

DeserializerFactory = ::WsdlMapper::Deserializers::DeserializerFactory.new

RUBY

      expected_file = @tmp_path.join("note_type_deserializer.rb")
      assert File.exists? expected_file

      generated_class = File.read expected_file
      assert_equal <<RUBY, generated_class
require "deserializer_factory"
require "note_type"

NoteTypeDeserializer = ::DeserializerFactory.register(nil, "noteType", ::NoteType) do
end
RUBY
    end
  end
end
