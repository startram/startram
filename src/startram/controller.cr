require "cgi"

module Startram
  abstract class Controller
    def initialize(@context)
    end

    macro def call(action) : Response
      Startram.log.debug "Processing by #{self.class}#{action} as #{accept || "unknown"}"
      Startram.log.debug "  Parameters: #{request.params}"

      {% public_methods = @type.methods.select { |m| m.visibility == :public } %}
      {% unless public_methods.empty? %}
        case action
          {% for method in public_methods %}
            when :{{method.name}} then {{method.name}}
          {% end %}
        end
      {% end %}

      response
    end

    macro layout(layout)
      {% layout_class = "Layouts"+layout.id.stringify.camelcase+"View" %}
      @layout_view_class = {{layout_class.id}}
    end

    macro view(action)
      {% view_class = @type.id.gsub(/Controller\z/, "")+action.id.stringify.camelcase+"View" %}
      view_instance = {{view_class.id}}.new(self)

      if @layout_view_class
        content = view_instance.to_s
        layout_instance = @layout_view_class.not_nil!.new(self, content: content)
        view_instance = layout_instance
      end

      render body: view_instance.to_s
    end

    macro method_missing(name, args, block)
      {% raise "no way" unless name.id.stringify.ends_with?("path") %}

      @context.app.router.url_helpers.{{name.id}}({{*args}})
    end

    delegate session, @context
    delegate response, @context
    delegate request, @context

    private def render(body = "", content_type = "text/html", status = 200)
      response.body = body.to_s
      response.status = status.to_i
      response.headers["Content-Type"] ||= content_type
    end

    private def redirect_to(path)
      response.status = 302
      response.headers["Location"] = path
    end

    private def headers
      request.headers
    end

    private def accept
      headers.fetch("Accept", nil)
    end

    private def params
      request.params
    end
  end
end
