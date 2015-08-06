require "../rack/utils"

module Startram
  class Request
    getter path_params

    def initialize(@request : HTTP::Request)
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
      @params ||= begin
        params = {} of String => Rack::Utils::NestedParams
        params.merge! body_params
        params.merge! query_params
        params.merge! path_params
      end
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

    private def parse_parameters(string)
      Rack::Utils.parse_nested_query(string)
    end
  end
end
