module Startram
  class Request
    getter path_params

    def initialize(@request)
      @path_params = {} of String => String
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

    def path_params=(path_params)
      @params = nil # reset memoized params
      @path_params = path_params
    end

    def params
      @params ||= body_params.merge(query_params).merge(path_params)
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
end
