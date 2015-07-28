require "http/server"

require "./startram/*"

module Startram
  class App < HTTP::Handler
    def call(request)
      HTTP::Response.ok("text/plain", "Initiating hyperdrive...")
    end
  end
end
