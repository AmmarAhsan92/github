#!/usr/bin/env ruby

require 'rack'
require 'json'

class Server

  def call(env)
    # the request path
    path = env['PATH_INFO']
    case env['REQUEST_METHOD']
    when 'GET'
      ['200', {}, ['']]
    end
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
