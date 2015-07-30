require "http/server"
require "mime"

class Startram::Handlers::StaticFileHandler < HTTP::Handler
  def initialize(@public_path)
  end

  def call(request)
    file_path = @public_path + request.path

    if File.file?(file_path)
      HTTP::Response.new 200, File.read(file_path), HTTP::Headers{"Content-Type": content_type(file_path)}
    else
      call_next(request)
    end
  end

  private def content_type(path)
    extension_without_dot = File.extname(path)[1..-1]

    Mime.from_ext(extension_without_dot) || "application/octet-stream"
  end
end
