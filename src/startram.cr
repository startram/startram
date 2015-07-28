require "http/server"

require "./startram/*"

module Startram
  class App < HTTP::Handler
    def call(request)
      request = Request.new(request)

      if request.post?
        HTTP::Response.new(201, "Hyperdrive initiated...", HTTP::Headers{"Content-type": "text/plain"})
      else
        HTTP::Response.ok("text/plain", "Hyperdriving!")
      end
    end
  end

  class Request
    def initialize(@request)
    end

    forward_missing_to @request

    def body
      @request.body
    end

    def post?
      @request.method == "POST"
    end

    def path
      @request.path
    end

    def params
      body_params.merge(query_params)
    end

    def query_params
      @query_params ||= parse_parameters(query_string)
    end

    def body_params
      @post_params ||= parse_parameters(body)
    end

    def query_string
      URI.parse(path).query
    end

    private def parse_parameters(params_string)
      hash = {} of String => String
      params = params_string.to_s.split("&")

      unless params.empty?
        params.each do |param|
          if match = /^(?<key>[^=]*)(=(?<value>.*))?$/.match(param)
            key, value = param.split("=").map { |s| CGI.unescape(s) }

            hash[key as String] = value
          end
        end
      end

      hash
    end
  end

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
