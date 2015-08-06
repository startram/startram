require "activesupport/activesupport/core_ext/string"

module Startram
  class Router
    HTTP_METHODS = %w[GET POST PUT PATCH DELETE HEAD OPTIONS TRACE]

    def initialize
      @named_routes = {} of String => Route
      @routes = {} of String => Array(Route)

      HTTP_METHODS.each do |method|
        @routes[method] = [] of Route
      end
    end

    {% for method in HTTP_METHODS %}
      def {{method.id.downcase}}(path, controller_class, action, name = nil)
        block = -> (context : Context) { controller_class.new(context).call(action) }

        add_route({{method}}, path, name, &block)
      end

      def {{method.id.downcase}}(path, name = nil, &block : Context -> Response)
        add_route({{method}}, path, name, &block)
      end
    {% end %}

    def add_route(method, path, name, &block : Context -> Response)
      route = Route.new(path, &block)
      name = name || path.split("/").select { |s| !s.empty? }.join("_")

      @routes[method] << route
      @named_routes[name] = route
    end

    macro resources(name)
      {% controller = "#{name.id.stringify.camelcase.id}Controller".id %}

      resource_path = "/{{name.id}}"
      singular = {{name.id.stringify}}.singularize
      plural = {{name.id.stringify}}.pluralize

      get resource_path, {{controller}}, :index, name: plural
      get "#{resource_path}/new", {{controller}}, :new, name: "new_#{singular}"
      get "#{resource_path}/:id", {{controller}}, :show, name: singular
      get "#{resource_path}/:id/edit", {{controller}}, :edit, name: "edit_#{singular}"
      post resource_path, {{controller}}, :create, name: plural
      put "#{resource_path}/:id", {{controller}}, :update, name: singular
      delete "#{resource_path}/:id", {{controller}}, :destroy, name: singular
    end

    def draw
      with self yield
    end

    def match(method, path)
      @routes[method].find &.match?(path)
    end

    class URLHelpers
      def initialize(@named_routes)
      end

      macro method_missing(name, args, block)
        {% method_parts = name.id.stringify.split("_") %}
        {% suffix = method_parts.last %}
        {% route_name = method_parts.select {|s| s != "path" }.join("_") %}

        raise "Method not found '{{name.id}}' for #{self.class}" unless @named_routes.has_key?({{route_name}})

        route = @named_routes[{{route_name}}]
        route.path({{*args}})
      end
    end

    def url_helpers
      @url_helpers ||= URLHelpers.new(@named_routes)
    end
  end
end
