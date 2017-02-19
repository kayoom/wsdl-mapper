require 'wsdl_mapper_testing/fake_s8r'
require 'wsdl_mapper_testing/fake_d10r'

module WsdlMapperTesting
  class FakeOperation
    attr_accessor :input_s8r, :output_d10r, :input_d10r, :output_d8r

    def initialize
      @inputs = {}
      @outputs = {}
      @input_s8r = FakeS8r.new
      @output_s8r = FakeS8r.new
      @input_d10r = FakeD10r.new
      @output_d10r = FakeD10r.new
    end

    def input_for_body(body, input)
      @inputs[body] = input
    end

    def output_for_body(body, output)
      @outputs[body] = output
    end

    def new_input(_header: nil, body: nil)
      @inputs.fetch body
    end

    def new_output(_header: nil, body: nil)
      @outputs.fetch body
    end
  end
end
