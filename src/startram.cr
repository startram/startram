require "http/server"
require "logger"

require "./startram/**"

module Startram
  def self.log
    @@log ||= Logger.new(STDOUT).tap do |logger|
      logger.formatter = Logger::Formatter.new do |severity, datetime, progname, message, io|
        io << message
      end
    end
  end

  class App < HTTP::Handler
    getter router

    def initialize(@root)
      @router = Router.new
    end

    def call(request)
      request = Request.new(request)

      if route = router.match(request.params.fetch("_method", request.method), request.path)
        route.call(request).to_http_response
      else
        HTTP::Response.not_found
      end
    end

    def handlers
      [
        HTTP::ErrorHandler.new
        Startram::Handlers::StaticFileHandler.new("#{@root}/public")
        Startram::Handlers::RequestLogHandler.new
        self
      ]
    end

    def serve
      port = ENV["PORT"]? || 7777
      server = HTTP::Server.new(port.to_i, handlers)
      Startram.log.info "Listening to http://localhost:#{port}"
      server.listen
    end
  end
end
