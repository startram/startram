require "../src/startram"

class Middleware < HTTP::Handler
  def call(request)
    response = call_next(request)

    body = "#{response.body} awesome!"

    HTTP::Response.new(response.status_code, body, response.headers)
  end
end

server = HTTP::Server.new(7777, [Middleware.new, Startram::App.new])
puts "Listening to http://localhost:7777"
server.listen
