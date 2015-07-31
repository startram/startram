require "../../src/startram"

{{run "../../src/run_commands/view_compiler", "#{__DIR__}/app/views"}}

require "./app/**"

app = Startram::App.new(__DIR__)

app.router.draw do
  resources :stickers
end

app.serve
