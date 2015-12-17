module WsdlMapper
  module Runtime
    # This module includes a set of default middlewares used in {WsdlMapper::Runtime::SimpleHttpBackend} and {WsdlMapper::Runtime::AsyncHttpBackend}.
    #
    # ## Blocking
    # * {SimpleMessageFactory}
    # * {SimpleRequestFactory}
    # * {SimpleDispatcher}
    # * {SimpleResponseFactory}
    #
    # ## Async
    # * {AsyncMessageFactory}
    # * {AsyncRequestFactory}
    # * {AsyncDispatcher}
    # * {AsyncResponseFactory}
    module Middlewares
    end
  end
end
