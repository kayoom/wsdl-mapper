require 'faraday'

module WsdlMapperTesting
  class StubConnection < Faraday::Connection
    attr_reader :stubs

    def initialize
      @stubs = Faraday::Adapter::Test::Stubs.new
      @actions = {}
      @requests = {}
      super do
        adapter :test, @stubs
      end
    end

    def stub_post(url, body)
      @stubs.post url do
        [200, {}, body]
      end
    end

    def stub_action(url, action, body)
      hsh = @actions[url]
      unless hsh
        hsh = @actions[url] = {}
        @stubs.post url do |env|
          req_action = env.request_headers['SOAPAction']
          [200, {}, hsh[req_action]]
        end
      end
      hsh[action] = body
    end

    def stub_request(url, request, body)
      hsh = @requests[url]
      unless hsh
        hsh = @requests[url] = {}
        @stubs.post url do |env|
          req_request = env.body
          [200, {}, hsh[req_request]]
        end
      end
      hsh[request] = body
    end

    def stub_error(url, error)
      @stubs.post url do |env|
        raise error
      end
    end
  end
end
