require "../src/startram"

app = Startram::App.new

app.router.draw do
  get "/" do
    Startram::Response.new body: "Ready for take off..."
  end
end

app.serve
