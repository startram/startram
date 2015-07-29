module Startram
  class Route
    def initialize(path, controller_class, action)
      @path_regex = compile(path)
      @handler = -> (request : Request) { controller_class.new(request).call(action.to_s) }
    end

    def initialize(path, &block : Request -> Response)
      @path_regex = compile(path)
      @handler = block
    end

    def match?(path)
      @path_regex.match(path)
    end

    def call(request)
      @handler.call(request)
    end

    private def compile(path)
      trailing_slash = "/" if path.ends_with?("/")
      segments = path.split("/").join("/")
      /\A#{segments}#{trailing_slash}\z/
    end
  end
end
