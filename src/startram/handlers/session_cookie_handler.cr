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
        context.session.deserialize!(session_cookie)
      end
    end

    private def set_session_cookie
      value = context.session.serialize

      context.response.set_cookie(session_key, value, path: "/", httponly: true)
    end

    private def context
      @context.not_nil!
    end
  end
end
