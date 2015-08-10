require "../src/startram"

class Middleware < HTTP::Handler
  def call(request)
    response = call_next(request)

    params = Startram::Request.new(request).params
    body = "#{response.body} #{params}!"

    HTTP::Response.new(response.status_code, body, response.headers)
  end
end

class HelloWorld < Startram::App
  routes do
    get "/" do |context|
      context.response.status = 200
      context.response.body = "Ready for take off..."
    end
  end
end

server = HTTP::Server.new(7777, [Middleware.new, HelloWorld.new])
Startram.log.info "Listening to http://localhost:7777"
server.listen
