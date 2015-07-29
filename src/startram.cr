require "http/server"

require "./startram/*"

module Startram
  METHODS = %w[GET POST PUT PATCH DELETE]

  class App < HTTP::Handler
    def initialize
      @routes = {
        "GET" => [] of Route
        "POST" => [] of Route
        "PUT" => [] of Route
        "PATCH" => [] of Route
        "DELETE" => [] of Route
      }
    end

    {% for method in METHODS %}
      def {{method.id.downcase}}(path, controller_class, action)
        @routes[{{method}}] << Route.new(path, controller_class.new, action)
      end
    {% end %}

    def draw
      with self yield
    end

    def call(request)
      request = Request.new(request)

      match = @routes[request.method].find &.match?(request.path)

      if match
        match.call(request)
      else
        HTTP::Response.not_found
      end
    end
  end
end
