require "../../src/startram"

{{run "../../src/run_commands/view_compiler", "#{__DIR__}/app/views"}}

require "./app/**"

Startram.log.level = Logger::WARN

class Showdown < Startram::App
  routes do
    get "/:title", PagesController, :index
  end
end

Showdown.new.serve
