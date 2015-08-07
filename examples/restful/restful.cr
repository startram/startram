require "../../src/startram"

{{run "../../src/run_commands/view_compiler", "#{__DIR__}/app/views"}}

require "./app/**"

app = Startram::App.new(root: __DIR__, session_key: "_restful_session")

app.router.draw do
  resources :stickers
end

app.serve
