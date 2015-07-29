module Startram
  class Route
    getter controller

    def initialize(path, @controller : Controller)
      @path_regex = compile(path)
    end

    def match?(path)
      @path_regex.match(path)
    end

    private def compile(path)
      trailing_slash = "/" if path.ends_with?("/")
      segments = path.split("/").join("/")
      /\A#{segments}#{trailing_slash}\z/
    end
  end
end
