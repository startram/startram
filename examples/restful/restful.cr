require "../../src/startram"

{{run "../../src/run_commands/view_compiler", "#{__DIR__}/app/views"}}

require "./app/**"

class Restful < Startram::App
  routes do
    get "/" do |context|
      context.response.status = 302
      context.response["Location"] = "/stickers"
    end

    resources :stickers
  end
end

app = Restful.new({
  "root" => __DIR__
  "session_key" => "_restful_session"
})

app.serve
