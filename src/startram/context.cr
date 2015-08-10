module Startram
  class Context
    getter request
    getter app
    getter response
    getter session
    getter flash

    def initialize(@request : Startram::Request, @app : App, @handlers = [] of Handler)
      @current_index = -1
      @response = Response.new(404)
      @session = Session.new
      @flash = Flash.new
    end

    def next
      @current_index += 1

      if handler = @handlers[@current_index]?
        handler.call(self)
      end
    end
  end
end
