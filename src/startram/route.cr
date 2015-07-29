module Startram
  class Route
    def initialize(path, @controller_class, @action)
      @path_regex = compile(path)
    end

    def match?(path)
      @path_regex.match(path)
    end

    def call(request)
      @controller_class.new(request).call(@action.to_s)
    end

    private def compile(path)
      trailing_slash = "/" if path.ends_with?("/")
      segments = path.split("/").join("/")
      /\A#{segments}#{trailing_slash}\z/
    end
  end
end
