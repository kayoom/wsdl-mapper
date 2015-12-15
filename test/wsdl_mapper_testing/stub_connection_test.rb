require 'test_helper'

require 'wsdl_mapper_testing/stub_connection'
require 'wsdl_mapper/runtime/errors'

class StubConnectionTest < Minitest::Test
  def test_simple_stubbing
    cnx = WsdlMapperTesting::StubConnection.new
    cnx.stub_post '/some-url', 'lorem ipsum'

    response = cnx.post '/some-url'

    assert_equal 'lorem ipsum', response.body
  end

  def test_action_stubbing
    cnx = WsdlMapperTesting::StubConnection.new
    cnx.stub_action '/some-url', 'SomeAction', 'lorem ipsum'
    cnx.stub_action '/some-url', 'SomeOtherAction', 'foo bar'

    response1 = cnx.post '/some-url' do |req|
      req['SOAPAction'] = 'SomeAction'
    end
    response2 = cnx.post '/some-url' do |req|
      req['SOAPAction'] = 'SomeOtherAction'
    end

    assert_equal 'lorem ipsum', response1.body
    assert_equal 'foo bar', response2.body
  end

  def test_request_stubbing
    cnx = WsdlMapperTesting::StubConnection.new
    cnx.stub_request '/some-url', 'some request', 'lorem ipsum'
    cnx.stub_request '/some-url', 'some other request', 'foo bar'

    response1 = cnx.post '/some-url', 'some request'

    assert_equal 'lorem ipsum', response1.body
  end

  def test_error_raising
    cnx = WsdlMapperTesting::StubConnection.new
    cnx.stub_error '/some-url', WsdlMapper::Runtime::Errors::TransportError.new('some error occured')

    begin
      response = cnx.post '/some-url', 'some request'
      assert false, 'Error not risen'
    rescue WsdlMapper::Runtime::Errors::TransportError => e
      assert_equal 'some error occured', e.message
    rescue => e
      assert false, "Did not expect error of type #{e.class}: #{e.message}"
    end
  end
end
