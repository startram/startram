module Startram
  class Context
    getter request
    getter app
    getter response

    def initialize(@request : Startram::Request, @app : App)
      @response = Response.new(404)
    end

    def params

    end
  end
end
