require "../../src/startram"

{{run "../../src/run_commands/view_compiler", "#{__DIR__}/app/views"}}

require "./app/**"

Startram.log.level = Logger::WARN

app = Startram::App.new

app.router.draw do
  get "/:title", PagesController, :index
end

app.serve
