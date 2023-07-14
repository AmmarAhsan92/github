#!/usr/bin/env ruby

require 'rack'
require 'json'
require 'digest'
require_relative 'response_helpers'
class Server
  include ResponseHelpers

  def initialize
    @repositories = Hash.new { |hash, key| hash[key] = {} }
  end

  def call(env)
    request = Rack::Request.new(env)

    case request.request_method
    when 'GET'
      handle_get(request)
    when 'PUT'
      handle_put(request)
    when 'DELETE'
      handle_delete(request)
    else
      method_not_allowed
    end
  end

  private

  def handle_get(request)
    repository, object_id = extract_repository_and_object_id(request.path_info)
    repository_data = @repositories[repository]

    if repository_data.key?(object_id)
      content = repository_data[object_id]
      ok_response(content)
    else
      not_found_response
    end
  end

  def handle_put(request)
    repository, _ = extract_repository_and_object_id(request.path_info)
    content = request.body.read

    object_id = Digest::SHA256.hexdigest(content)
    repository_data = @repositories[repository]

    if repository_data.key?(object_id)
      ok_response
    else
      repository_data[object_id] = content
      created_response(object_id, content)
    end
  end

  def handle_delete(request)
    repository, object_id = extract_repository_and_object_id(request.path_info)
    repository_data = @repositories[repository]

    if repository_data.key?(object_id)
      repository_data.delete(object_id)
      ok_response
    else
      not_found_response
    end
  end

  def extract_repository_and_object_id(path_info)
    path_info.split('/')[2..3]
  end
end

# This starts the server if the script is invoked from the command line. No
# modifications needed here.
if __FILE__ == $0
  app = Rack::Builder.new do
    use Rack::Reloader
    run Server.new
  end.to_app

  Rack::Server.start(app: app, Port: 8282)
end
