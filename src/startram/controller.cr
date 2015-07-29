module Startram
  abstract class Controller < HTTP::Handler
    def initialize(@request, @response = Response.new 404)
    end

    macro def call(method_name) : Response
      {% unless @type.abstract? %} # not applicable to base Controller
        case method_name.to_s
        {% for method in @type.methods %}
          {% if method.args.length == 0 %}
            when {{method.name.stringify}} then {{method.name}}
          {% end %}
        {% end %}
        end
      {% end %}

      @response
    end

    def render(body = "", content_type = "text/html", status = 200)
      @response.body = body
      @response.status = status
      @response.headers["Content-Type"] ||= content_type
    end

    def params
      @request.params
    end
  end
end
