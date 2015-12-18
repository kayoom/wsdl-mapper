module WsdlMapperTesting
  class FakeD10r
    def initialize
      @outputs = {}
    end

    def output_for_xml(xml, output)
      @outputs[xml] = output
    end

    def from_xml(xml)
      @outputs.fetch xml
    end
  end
end
