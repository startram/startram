module Startram
  class Route
    def initialize(path, &block : Context -> Response)
      @path = path
      @named_parameters = Set(String).new
      @path_regex = compile(path)
      @handler = block
    end

    def path(*args)
      path = @path

      if args.length != @named_parameters.length
        raise ArgumentError.new("Expected arguments for :#{@named_parameters.join(", :")}, got: #{args}")
      end

      @named_parameters.each_with_index do |name, index|
        path = path.gsub(":#{name}", args[index])
      end

      path
    end

    def match?(path)
      path_before_query_or_anchor = path.split(/[\?#]/).first
      @path_regex.match(path_before_query_or_anchor)
    end

    def call(context)
      context.request.path_params = path_params(context.request.path)
      @handler.call(context)
    end

    private def compile(path)
      trailing_slash = "/" if path.ends_with?("/")

      segments = path.split("/").map do |segment|
        segment.gsub(/:(?<name>\w+)/) do |s, m|
          name = m["name"]

          if @named_parameters.includes?(name)
            raise "ERROR: Can't have multiple named parameters in a route with the same name (#{name})"
          end

          @named_parameters << name
          "(?<#{name}>[^/?#]+)"
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
