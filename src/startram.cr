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
      def {{method.id.downcase}}(path, controller)
        @routes[{{method}}] << Route.new(path, controller)
      end
    {% end %}

    def draw
      with self yield
    end

    def call(request)
      request = Request.new(request)

      match = @routes[request.method].find &.match?(request.path)

      if match
        match.controller.call(request)
      else
        HTTP::Response.not_found
      end
    end
  end

  class Route
    getter controller

    def initialize(path, @controller : Controller)
      @path_regex = compile(path)
    end

    def match?(path)
      @path_regex.match(path)
    end

    private def compile(path)
      trailing_slash = "/" if path.ends_with?("/")
      segments = path.split("/").join("/")
      /\A#{segments}#{trailing_slash}\z/
    end
  end

  abstract class Controller < HTTP::Handler
    def call(request : Request)
    end
  end

  class Request
    def initialize(@request)
    end

    forward_missing_to @request

    def body
      @request.body
    end

    def post?
      @request.method == "POST"
    end

    def path
      @request.path
    end

    def params
      body_params.merge(query_params)
    end

    def query_params
      @query_params ||= parse_parameters(query_string)
    end

    def body_params
      @post_params ||= parse_parameters(body)
    end

    def query_string
      URI.parse(path).query
    end

    private def parse_parameters(params_string)
      hash = {} of String => String
      params = params_string.to_s.split("&")

      unless params.empty?
        params.each do |param|
          if match = /^(?<key>[^=]*)(=(?<value>.*))?$/.match(param)
            key, value = param.split("=").map { |s| CGI.unescape(s) }

            hash[key as String] = value
          end
        end
      end

      hash
    end
  end

  class Response < HTTP::Response
    getter body
    getter headers

    def initialize(status = 200, body = "", headers = HTTP::Headers.new)
      super status, body, headers
    end

    def []=(key, value)
      headers.add(key, value.to_s)
    end

    def [](key)
      headers[key]
    end

    def write(text)
      @body += text
      @headers["Content-Length"] = [@body.length.to_s]
    end
  end
end
