require "spec"
require "../src/startram"

def build_request(method, path, body = "Test", headers = HTTP::Headers.new)
  base_request = HTTP::Request.new(method, path, headers, body)

  Startram::Request.new(base_request)
end
