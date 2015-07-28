require "../src/startram"

server = HTTP::Server.new(7777, Startram::App.new)
puts "Listening to http://localhost:7777"
server.listen
