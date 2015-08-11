module Startram
  class Session
    def initialize
      @store = {} of String => String
    end

    def deserialize!(cookie_string)
      cookie_string.split("&").each do |key_value|
        key, value = key_value.split("=")

        @store[key] = value
      end
    end

    # Array plays nicely with Rack::Utils which joins arrays using '&' later on
    def serialize
      @store.map do |key, value|
        "#{key}=#{value}"
      end.join('&')
    end

    forward_missing_to @store
  end
end
