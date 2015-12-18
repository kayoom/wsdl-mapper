module WsdlMapperTesting
  class FakeS8r
    def initialize
      @xmls = {}
    end

    def xml_for_input(input, xml)
      @xmls[input] = xml
    end

    def to_xml(input)
      @xmls.fetch input
    end
  end
end
