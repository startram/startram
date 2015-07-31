require "cgi"

module Startram
  abstract class Controller
    def initialize(@request)
      @response = Response.new 404
    end

    macro def call(action) : Response
      puts "Processing by #{self.class}#{action} as #{accept || "unknown"}"
      puts "  Parameters: #{@request.params}"

      case action
        {% for method in @type.methods.select { |m| m.visibility == :public } %}
          when :{{method.name}} then {{method.name}}
        {% end %}
      end

      @response
    end

    macro view(action)
      {% view_class = @type.id.gsub(/Controller\z/, "")+action.id.stringify.camelcase+"View" %}
      view_instance = {{view_class.id}}.new(self)

      render body: view_instance.to_s
    end

    private def render(body = "", content_type = "text/html", status = 200)
      @response.body = body
      @response.status = status
      @response.headers["Content-Type"] ||= content_type
    end

    private def redirect_to(path)
      @response.status = 302
      @response.headers["Location"] = path
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
