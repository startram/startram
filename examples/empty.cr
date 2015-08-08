require "../src/startram"

# run this to make sure we don't get compiler error on app without routes

app = Startram::App.new

app.router.draw do
end

app.serve
