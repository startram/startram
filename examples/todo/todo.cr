require "../../src/startram"

require "./app/**"

class VariousThings < Startram::App
  routes do
    get "/todos", TodosController, :index
    get "/todos/:id", TodosController, :show
    get "/weather/status", WeatherController, :status
    get "/" { |context| Startram::Response.new body: "root :D" }
    get "/params/:path_param" { |context| Startram::Response.new body: context.request.params.inspect }
    get "/slow" { |context| sleep 0.3; Startram::Response.new body: "slow :/" }
  end
end

app = VariousThings.new({
  "root" => __DIR__
  "session_key" => "_todo_session"
})

app.serve
