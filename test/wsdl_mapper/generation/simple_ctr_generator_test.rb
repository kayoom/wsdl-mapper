require 'test_helper'

require 'wsdl_mapper/schema/parser'
require 'wsdl_mapper/generation/context'
require 'wsdl_mapper/generation/generator'
require 'wsdl_mapper/generation/simple_ctr_generator'

require 'wsdl_mapper/dom/property'

module GenerationTests
  module GeneratorTests
    class SimpleCtrGeneratorTest < Minitest::Test
      include WsdlMapper::Generation
      include WsdlMapper::Dom

      def setup
        @tmp_path = TestHelper.get_tmp_path
      end

      def teardown
        @tmp_path.unlink
      end

      def test_simple_class_generation
        schema = TestHelper.parse_schema 'example_1.xsd'
        context = Context.new @tmp_path.to_s
        generator = Generator.new context, ctr_generator_factory: SimpleCtrGenerator

        result = generator.generate schema

        expected_file = @tmp_path.join("note_type.rb")

        generated_class = File.read expected_file
        assert_equal <<RUBY, generated_class
class NoteType
  attr_accessor :to, :from, :heading, :body

  def initialize(to: nil, from: nil, heading: nil, body: nil)
    @to = to
    @from = from
    @heading = heading
    @body = body
  end
end
RUBY
      end
    end
  end
end

