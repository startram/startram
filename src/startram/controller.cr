require "cgi"

module Startram
  abstract class Controller
    def initialize(@request)
      @response = Response.new 404
    end

    macro def call(method_name) : Response
      puts "Processing by #{self.class}#{method_name} as #{accept || "unknown"}"
      puts "  Parameters: #{@request.params}"

      case method_name
        {% for method in @type.methods.select { |m| m.visibility == :public } %}
          when :{{method.name}} then {{method.name}}
        {% end %}
      end

      @response
    end

    private def render(body = "", content_type = "text/html", status = 200)
      @response.body = body
      @response.status = status
      @response.headers["Content-Type"] ||= content_type
    end

    private def headers
      @request.headers
    end

    private def accept
      headers.fetch("Accept", nil)
    end

    private def params
      @request.params
    end
  end
end
