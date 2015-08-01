require "../src/startram"

class Middleware < HTTP::Handler
  def call(request)
    response = call_next(request)

    params = Startram::Request.new(request).params
    body = "#{response.body} #{params}!"

    HTTP::Response.new(response.status_code, body, response.headers)
  end
end

app = Startram::App.new

app.router.draw do
  get "/" do
    Startram::Response.new body: "Ready for take off..."
  end
end

server = HTTP::Server.new(7777, [Middleware.new, app])
Startram.log.info "Listening to http://localhost:7777"
server.listen
