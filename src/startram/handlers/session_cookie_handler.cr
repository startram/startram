module Startram
  class Handlers::SessionCookieHandler < Handler
    getter session_key

    def initialize(@session_key : String)
    end

    def call(context)
      @context = context

      populate_session_from_cookie

      context.next

      set_session_cookie
    end

    private def populate_session_from_cookie
      if session_cookie = context.request.cookies[session_key]?
        session_cookie.split("&").each do |key_value|
          key, value = key_value.split("=")

          context.session[key] = value
        end
      end
    end

    private def set_session_cookie
      values = context.session.map do |key, value|
        "#{key}=#{value}"
      end

      context.response.set_cookie(session_key, values, path: "/", httponly: true)
    end

    private def context
      @context.not_nil!
    end
  end
end
