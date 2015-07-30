require "../../src/startram"

require "./app/**"

app = Startram::App.new(__DIR__)

app.router.draw do
  resources :stickers
end

app.serve
