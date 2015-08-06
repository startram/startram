require "spec"
require "../src/startram"

Startram.log.level = Logger::WARN

def build_request(method, path, body = "Test", headers = HTTP::Headers.new)
  base_request = HTTP::Request.new(method, path, headers, body)

  Startram::Request.new(base_request)
end
