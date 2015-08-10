require "./view/helpers/*"

module Startram
  abstract class View
    include Helpers

    getter content

    # @content is for the layouts, used with <%= content %> rather than <%= yield %>
    def initialize(@controller, @content = nil)
    end

    delegate flash, @controller

    macro method_missing(name, args, block)
      {% if name.id.stringify.ends_with?("path") %}
        @controller.{{name.id}}({{*args}})
      {% else %}
        @controller.@{{name.id}}.not_nil!
      {% end %}
    end
  end
end
