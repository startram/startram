require "../src/startram"

# run this to make sure we don't get compiler error on app without routes

class EmptyApp < Startram::App
  routes do
  end
end

EmptyApp.new.serve
