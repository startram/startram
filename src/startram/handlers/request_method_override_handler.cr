module Startram
  class Handlers::RequestMethodOverrideHandler < Handler
    ALLOWED_OVERRIDES = %w[PUT PATCH DELETE]
    OVERRIDE_PARAM = "_method"

    def call(context)
      request = context.request

      if request.method == "POST" && request.params.has_key?(OVERRIDE_PARAM)
        method = request.params[OVERRIDE_PARAM].to_s.upcase

        request.method = method if ALLOWED_OVERRIDES.includes?(method)
      end

      context.next
    end
  end
end
