module Startram
  class Handlers::SessionCookieHandler < Handler
    getter session_key

    def initialize(@session_key : String, @secret_key_base : String)
      if @secret_key_base.empty?
        Startram.log.warn "Set app config secret_key_base to encrypt your cookies"
      elsif @secret_key_base.length < 64
        Startram.log.warn "App config secret_key_base should be at least 64 characters long"
      end

      @session_encoder = Session::Encoder.new(@secret_key_base)
    end

    def call(context)
      @context = context

      populate_session_from_cookie

      context.next

      set_session_cookie
    end

    private def populate_session_from_cookie
      if session_cookie = context.request.cookies[session_key]?
        decoded_cookie = @session_encoder.decode(session_cookie)

        context.session.deserialize!(decoded_cookie)
      end
    end

    private def set_session_cookie
      encoded_cookie_value = @session_encoder.encode(context.session.serialize)

      context.response.set_cookie(session_key, encoded_cookie_value, path: "/", httponly: true)
    end

    private def context
      @context.not_nil!
    end
  end
end
