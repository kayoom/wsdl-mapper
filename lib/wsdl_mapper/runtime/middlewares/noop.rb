module WsdlMapper
  module Runtime
    module Middlewares
      class Noop
        def call(*args)
          args
        end
      end
    end
  end
end
