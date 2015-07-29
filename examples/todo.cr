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

class TodoList < Startram::Controller
  def index
    tasks = Task.all

    if @request.not_nil!.headers["Accept"].includes?("json")
      render body: tasks.to_json, content_type: "application/json"
    else
      render body: TodosView.new(tasks).to_s
    end
  end
end

app = App.new

app.draw do
  get "/todos", TodoList, :index
end

server = HTTP::Server.new(7777, app)
puts "Listening to http://localhost:7777"
server.listen
