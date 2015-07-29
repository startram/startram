module Startram
  class Router
    HTTP_METHODS = %w[GET POST PUT PATCH DELETE]

    def initialize
      @routes = {
        "GET" => [] of Route
        "POST" => [] of Route
        "PUT" => [] of Route
        "PATCH" => [] of Route
        "DELETE" => [] of Route
      }
    end

    {% for method in HTTP_METHODS %}
      def {{method.id.downcase}}(path, controller_class, action)
        @routes[{{method}}] << Route.new(path, controller_class, action)
      end

      def {{method.id.downcase}}(path, &block : Request -> Response)
        @routes[{{method}}] << Route.new(path, &block)
      end
    {% end %}

    def draw
      with self yield
    end

    def match(method, path)
      @routes[method].find &.match?(path)
    end
  end
end
