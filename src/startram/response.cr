module Startram
  class Response
    property body
    property status
    getter headers

    def initialize(@status = 200, @body = "", @headers = HTTP::Headers.new)
    end

    def []=(key, value)
      headers.add(key, value.to_s)
    end

    def [](key)
      headers[key]
    end

    def to_http_response
      HTTP::Response.new @status, @body, @headers
    end
  end
end
