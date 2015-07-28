require "http/server"

require "./startram/*"

module Startram
  class App < HTTP::Handler
    def call(request)
      request = Request.new(request)

      if request.post?
        HTTP::Response.new(201, "Hyperdrive initiated...", HTTP::Headers{"Content-type": "text/plain"})
      else
        HTTP::Response.ok("text/plain", "Hyperdriving!")
      end
    end
  end

  class Request
    def initialize(@request)
    end

    def post?
      @request.method == "POST"
    end
  end
end
