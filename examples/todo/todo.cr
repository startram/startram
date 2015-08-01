require "../../src/startram"

require "./app/**"

app = Startram::App.new(__DIR__)

app.router.draw do
  get "/todos", TodosController, :index
  get "/todos/:id", TodosController, :show
  get "/weather/status", WeatherController, :status
  get "/" { |request| Startram::Response.new body: "root :D" }
  get "/params/:path_param" { |request| Startram::Response.new body: request.params.inspect }
  get "/slow" { |request| sleep 0.3; Startram::Response.new body: "slow :/" }
end

app.serve
