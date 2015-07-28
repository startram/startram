require "../src/startram"

class Middleware < HTTP::Handler
  def call(request)
    response = call_next(request)

    params = Startram::Request.new(request).params
    body = "#{response.body} #{params}!"

    HTTP::Response.new(response.status_code, body, response.headers)
  end
end

server = HTTP::Server.new(7777, [Middleware.new, Startram::App.new])
puts "Listening to http://localhost:7777"
server.listen
