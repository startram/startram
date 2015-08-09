module Startram
  class View
    module Helpers
      def form_for(model)
        FormBuilder.new(model)
      end

      class FormBuilder
        def initialize(@model)
        end

        def begin
          method = @model.persisted? ? "PUT" : "POST"
          action = @model.persisted? ? "/#{resource_name}/#{@model.id}" : "/#{resource_name}"

          String.build do |str|
            str << %(<form method="POST" action="#{action}">)
            str << %(<input type="hidden" name="_method" value="#{method}">) unless method == "POST"
          end
        end

        def end
          %(</form>)
        end

        def input(attribute, value = nil) : String
          value ||= @model.attributes[attribute.to_s]?
          %(<input type="text" name="#{param_name}[#{attribute}]" value="#{value}">)
        end

        private def param_name
          @model.class.to_s.underscore
        end

        private def resource_name
          @model.class.to_s.tableize
        end
      end
    end
  end
end
