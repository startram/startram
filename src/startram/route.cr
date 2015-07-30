module Startram
  class Route
    def initialize(path, controller_class, action)
      @path_regex = compile(path)
      @handler = -> (request : Request) { controller_class.new(request).call(action) }
    end

    def initialize(path, &block : Request -> Response)
      @path_regex = compile(path)
      @handler = block
    end

    def match?(path)
      path_before_query_or_anchor = path.split(/[\?#]/).first
      @path_regex.match(path_before_query_or_anchor)
    end

    def call(request)
      request.path_params = path_params(request.path)
      @handler.call(request)
    end

    private def compile(path)
      trailing_slash = "/" if path.ends_with?("/")

      segments = path.split("/").map do |segment|
        segment.gsub(/:(?<name>\w+)/) do |s, m|
          "(?<#{m["name"]}>[^/?#]+)"
        end
      end

      joined = segments.join("/")

      /\A#{joined}#{trailing_slash}\z/
    end

    private def path_params(path)
      match = match?(path) as MatchData
      params = {} of String => String

      @path_regex.name_table.each do |index, name|
        params[name] = match[index]
      end

      params
    end
  end
end
