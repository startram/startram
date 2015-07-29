module Startram
  abstract class Controller < HTTP::Handler
    macro def call(method_name, request) : Response
      @request = request

      case method_name.to_s
      {% for method in @type.methods %}
        {% if method.args.length == 0 %}
          when {{method.name.stringify}} then return {{method.name}}
        {% end %}
      {% end %}
      end

      Response.new 404
    end
  end
end
