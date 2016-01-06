require 'vcr'
require 'webmock'

module WsdlMapperTesting
  module Vcr
    extend self

    def prepare(cassette_dir, &block)
      ::VCR.configure do |c|
        c.hook_into                :webmock
        c.cassette_library_dir     = cassette_dir
        c.default_cassette_options = {
          match_requests_on: [:uri, :body]
        }
        block[c] if block
      end
    end
  end
end
