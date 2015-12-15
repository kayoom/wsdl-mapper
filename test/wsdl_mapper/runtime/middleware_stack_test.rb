require 'test_helper'

require 'wsdl_mapper/runtime/middleware_stack'

module RuntimeTests
  class MiddlewareStackTest < WsdlMapperTesting::Test
    include WsdlMapper::Runtime

    def test_add
      stack = MiddlewareStack.new

      stack.add 'some.middleware', Object.new

      assert_equal 1, stack.count
    end

    def test_names
      stack = MiddlewareStack.new

      stack.add 'some.middleware', Object.new
      stack.add 'some.other.middleware', Object.new

      assert_equal ['some.middleware', 'some.other.middleware'], stack.names
    end

    def test_replace
      stack = MiddlewareStack.new
      middleware_old = Object.new
      stack.add 'some.middleware', middleware_old

      middleware_new = Object.new
      stack.replace 'some.middleware', middleware_new

      assert_equal [middleware_new], stack.to_a
    end

    def test_clear
      stack = MiddlewareStack.new
      stack.add 'some.middleware', Object.new

      stack.clear

      assert_equal 0, stack.count
    end

    def test_remove
      stack = MiddlewareStack.new

      stack.add 'some.middleware', Object.new
      stack.add 'some.other.middleware', Object.new

      stack.remove 'some.middleware'

      assert_equal ['some.other.middleware'], stack.names
    end

    def test_get
      stack = MiddlewareStack.new
      middleware = Object.new
      stack.add 'some.middleware', middleware

      assert_equal middleware, stack.get('some.middleware')
    end

    def test_get_error
      stack = MiddlewareStack.new
      middleware = Object.new
      stack.add 'some.middleware', middleware

      begin
        stack.get('some.other.middleware')
        assert false
      rescue => e
        assert_kind_of ArgumentError, e
        assert_equal 'some.other.middleware not found.', e.message
      end
    end

    def test_prepend
      stack = MiddlewareStack.new

      stack.add 'some.other.middleware', Object.new
      stack.prepend 'some.middleware', Object.new

      assert_equal ['some.middleware', 'some.other.middleware'], stack.names
    end

    def test_after
      stack = MiddlewareStack.new

      stack.add 'some.other.middleware', Object.new
      stack.add 'some.more.middleware', Object.new
      stack.after 'some.other.middleware', 'some.middleware', Object.new

      assert_equal ['some.other.middleware', 'some.middleware', 'some.more.middleware'], stack.names
    end

    def test_before
      stack = MiddlewareStack.new

      stack.add 'some.other.middleware', Object.new
      stack.add 'some.more.middleware', Object.new
      stack.before 'some.more.middleware', 'some.middleware', Object.new

      assert_equal ['some.other.middleware', 'some.middleware', 'some.more.middleware'], stack.names
    end

    def test_each
      stack = MiddlewareStack.new
      middleware1 = Object.new
      stack.add 'some.middleware', middleware1
      middleware2 = Object.new
      stack.add 'some.middleware', middleware2

      middlewares = stack.each.to_a

      assert_equal middlewares, [middleware1, middleware2]
    end

    def test_execute
      stack = MiddlewareStack.new
      stack.add 'first', ->(input) { [input.upcase, 'ipsum'] }
      stack.add 'second', -> (input1, input2) { (input1 + input2).reverse }

      output = stack.execute 'lorem'

      assert_equal 'muspiMEROL', output
    end
  end
end
