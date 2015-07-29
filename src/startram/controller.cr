module Startram
  abstract class Controller < HTTP::Handler
    def initialize(@request, @response = Response.new 404)
    end

    macro def call(method_name) : HTTP::Response
      case method_name.to_s
      {% for method in @type.methods %}
        {% if method.args.length == 0 %}
          when {{method.name.stringify}} then {{method.name}}
        {% end %}
      {% end %}
      end

      @response.to_http_response
    end

    def render(body = "", content_type = "text/html")
      @response.body = body
      @response.headers["Content-Type"] ||= content_type
    end
  end
end
