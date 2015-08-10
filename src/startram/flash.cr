module Startram
  class Flash
    def initialize
      @current = {} of String => String
      @next = {} of String => String
    end

    def set_current_from_session!(session : Session)
      flash_keys = session.keys.select &.starts_with?("flash.")

      flash_keys.each do |flash_key|
        _, key = flash_key.split(".")

        @current[key] = session.delete(flash_key) as String
      end
    end

    def update_session(session : Session)
      @next.each do |key, value|
        session["flash.#{key}"] = value
      end
    end

    def []=(key, value)
      @next[key] = value
    end

    def [](key)
      @current[key]
    end

    def []?(key)
      @current[key]?
    end

    forward_missing_to @current
  end
end
