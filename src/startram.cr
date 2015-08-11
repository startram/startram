require "http/server"
require "logger"

require "./startram/**"

module Startram
  def self.log
    @@log ||= Logger.new(STDOUT).tap do |logger|
      logger.formatter = Logger::Formatter.new do |severity, datetime, progname, message, io|
        io << message
      end

      logger.level = Logger::DEBUG
    end
  end

  class App < HTTP::Handler
    def self.router
      @@router ||= Router.new
    end

    def self.routes
      with router yield
    end

    def self.configure(additional_config : Hash(String, String))
      config.merge! additional_config
    end

    def self.config
      @@config ||= {
        "root" => Dir.working_directory
        "session_key" => "_startram_session"
      }
    end

    getter :router
    getter :config

    def initialize(config = {} of String => String)
      @router = self.class.router
      @config = self.class.config.merge(config)
    end

    def call(request)
      request = Request.new(request)
      context = Context.new(request, self, app_handlers)

      context.next

      context.response.to_http_response
    end

    def app_handlers
      @app_handlers ||= [
        Startram::Handlers::RequestMethodOverrideHandler.new
        Startram::Handlers::SessionCookieHandler.new(config["session_key"])
        Startram::Handlers::FlashHandler.new
        router
      ]
    end

    def handlers
      [
        HTTP::ErrorHandler.new
        Startram::Handlers::StaticFileHandler.new("#{config["root"]}/public")
        Startram::Handlers::RequestLogHandler.new
        self
      ]
    end

    def serve
      add_default_routes if router.empty?

      port = ENV["PORT"]? || 7777
      server = HTTP::Server.new(port.to_i, handlers)
      Startram.log.info "Listening to http://localhost:#{port}"
      server.listen
    end

    private def add_default_routes
      router.draw do
        get "/" do |context|
          context.response.status = 200
          context.response.body = "
            <h1>Welcome to startram.</h1>
            <p>Better add your own routes to get rid of this screen...</p>
          "
        end
      end
    end
  end
end
