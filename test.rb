require 'minitest/autorun'
require 'rack/test'
require 'concurrent'
require_relative './server'

class ServerTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Server.new
  end

  def test_put
    put '/data/my-repo', 'something'
    res1 = JSON.parse(last_response.body)

    assert_equal 201, last_response.status
    assert_equal 'application/json', last_response.content_type
    assert_equal 9, res1['size']
    assert res1['oid'].is_a?(String)
    assert res1['oid'].length > 0

    put '/data/my-repo', 'other'
    res2 = JSON.parse(last_response.body)

    assert_equal 201, last_response.status
    assert_equal 'application/json', last_response.content_type
    assert res2['oid'].is_a?(String)
    assert res2['oid'].length > 0
    refute_equal res1['oid'], res2['oid']
  end

  def test_get
    put '/data/my-repo', 'something'
    res1 = JSON.parse(last_response.body)

    get "/data/my-repo/#{res1['oid']}"
    assert_equal 200, last_response.status
    assert_equal 'something', last_response.body
  end

  def test_get_not_found
    get '/data/my-repo/missing'
    assert_equal 404, last_response.status
  end

  def test_delete
    put '/data/my-repo', 'something'
    res = JSON.parse(last_response.body)

    put '/data/other-repo', 'something'
    dup_res = JSON.parse(last_response.body)

    delete "/data/my-repo/#{res['oid']}"
    assert_equal 200, last_response.status

    get "/data/my-repo/#{res['oid']}"
    assert_equal 404, last_response.status

    get "/data/other-repo/#{dup_res['oid']}"
    assert_equal 200, last_response.status
    assert_equal 'something', last_response.body
  end

  def test_delete_not_found
    delete '/data/my-repo/missing'
    assert_equal 404, last_response.status
  end

  def test_concurrent_requests
    counter = Concurrent::AtomicFixnum.new(0)

    executor = Concurrent::FixedThreadPool.new(5)

    10.times do
      executor.post do
        put '/data/my-repo', 'concurrent request'
        counter.increment if last_response.ok?
      end
    end

    executor.shutdown
    executor.wait_for_termination

    assert counter.value > 1
  end
end
