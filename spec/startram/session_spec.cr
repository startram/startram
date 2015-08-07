require "../spec_helper"

class SessionController < Startram::Controller
  def create
    session["user_id"] = "23"
  end

  def show
    render body: session["user_id"]
  end
end

app = Startram::App.new

app.router.draw do
  post "/session", SessionController, :create
  get "/session", SessionController, :show
end

module Startram
  describe Session do
    it "sets a session cookie" do
      request = HTTP::Request.new("POST", "/session")

      response = app.call(request)

      response.headers.get("Set-Cookie").should eq ["_startram_session=user_id%3D23; path=/; HttpOnly"]
    end

    it "reads a session cookie" do
      request = HTTP::Request.new(
        "GET", "/session", HTTP::Headers{"Cookie" => "_startram_session=user_id%3D23"}
      )

      response = app.call(request)

      response.body.should eq "23"
    end
  end
end
