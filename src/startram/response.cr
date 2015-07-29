module Startram
  class Response < HTTP::Response
    getter body
    getter headers

    def initialize(status = 200, body = "", headers = HTTP::Headers.new)
      super status, body, headers
    end

    def []=(key, value)
      headers.add(key, value.to_s)
    end

    def [](key)
      headers[key]
    end

    def write(text)
      @body += text
      @headers["Content-Length"] = [@body.length.to_s]
    end
  end
end
