module Startram
  class Response
    property body
    property status
    getter headers

    def initialize(@status = 200, @body = "", @headers = HTTP::Headers.new)
    end

    def []=(key, value : String | Array(String))
      headers[key] = value
    end

    def [](key)
      headers[key]
    end

    def set_cookie(key, value,
        domain = nil,
        path = nil,
        max_age = nil,
        secure = nil,
        expires = nil,
        httponly = nil
      )
      Rack::Utils.set_cookie_header!(
        headers, key, value,
        domain: domain,
        path: path,
        max_age: max_age,
        secure: secure,
        expires: expires,
        httponly: httponly
      )
    end

    def expire_cookie(key, domain = nil, path = nil)
      Rack::Utils.delete_cookie_header!(headers, key, domain: domain, path: path)
    end

    def to_http_response
      HTTP::Response.new @status, @body, @headers
    end
  end
end
