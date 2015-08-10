require "../src/startram"

class HelloWorld < Startram::App
  routes do
    get "/" do |context|
      context.response.status = 200
      context.response.body = "Ready for take off..."
    end
  end
end

HelloWorld.new.serve
