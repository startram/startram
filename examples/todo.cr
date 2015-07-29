require "../src/startram"

require "html/builder"
require "json"

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
      Response.new body: tasks.to_json, headers: HTTP::Headers{"Content-Type": "application/json"}
    else
      Response.new body: render_html(tasks), headers: HTTP::Headers{"Content-Type": "text/html"}
    end
  end

  private def render_html(tasks)
    HTML::Builder.new.build do
      h1 { text "Todos" }
      ul do
        tasks.each do |task|
          li { text task.name }
        end
      end
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
