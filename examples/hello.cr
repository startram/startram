require "../src/startram"

app = Startram::App.new

app.router.draw do
  get "/" do |context|
    context.response.status = 200
    context.response.body = "Ready for take off..."
  end
end

app.serve
