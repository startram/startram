require "../../src/startram"
require "json"

require "./app/**"

app = Startram::App.new

app.router.draw do
  get "/todos", TodosController, :index
  get "/todos/:id", TodosController, :show
  get "/weather/status", WeatherController, :status
  get "/" { |request| Startram::Response.new body: "root :D" }
  get "/slow" { |request| sleep 0.3; Startram::Response.new body: "slow :/" }
end

app.serve
