require "../src/startram"
require "json"

require "./views/todos_view"

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

    if accept.to_s.includes?("json")
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

app = Startram::App.new

app.router.draw do
  get "/todos", TodosController, :index
  get "/todos/:id", TodosController, :show
  get "/weather/status", WeatherController, :status
  get "/" { |request| Startram::Response.new body: "root :D" }
  get "/slow" { |request| sleep 0.3; Startram::Response.new body: "slow :/" }
end

app.serve
