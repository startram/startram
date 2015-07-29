require "../src/startram"
require "json"

require "./views/todos_view"

include Startram

class Task
  def self.all
    [
      Task.new("Make it rain!")
      Task.new("Snow is kinda cold!")
      Task.new("Snow is frozen")
    ]
  end

  property :name

  def initialize(@name)
  end

  json_mapping({
    "name" => String
  })
end

class TodosController < Startram::Controller
  def index
    tasks = Task.all

    if @request.headers["Accept"].includes?("json")
      render body: tasks.to_json, content_type: "application/json"
    else
      render body: TodosView.new(tasks).to_s
    end
  end

  def show
    render body: "Show: #{params}"
  end
end

class WeatherController < Startram::Controller
  def status
    render body: "It is sunny with a slight chance of apocalypse!"
  end
end

app = App.new

app.router.draw do
  get "/todos", TodosController, :index
  get "/todos/:id", TodosController, :show
  get "/weather/status", WeatherController, :status
  get "/" { |request| Response.new body: "root :D" }
end

server = HTTP::Server.new(7777, app)
puts "Listening to http://localhost:7777"
server.listen
