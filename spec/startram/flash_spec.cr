require "../spec_helper"

class FlashController < Startram::Controller
  def update
    flash["notice"] = "Hello"
    flash["error"] = "Ohno"

    render body: "notice: #{flash["notice"]?}, error: #{flash["error"]?}"
  end
end

class SessionTestApp < Startram::App
  routes do
    put "/session", FlashController, :update
  end
end

app = SessionTestApp.new

module Startram
  describe Flash do
    context "integrated in request lifecycle" do
      it "uses the previous session in render pipeline" do
        request = HTTP::Request.new(
          "PUT", "/session", HTTP::Headers{"Cookie" => "_startram_session=flash.notice%3DThis"}
        )

        response = app.call(request)

        response.body.should eq "notice: This, error: "

        response.headers.get("Set-Cookie").should eq [
          "_startram_session=flash.notice%3DHello&flash.error%3DOhno; path=/; HttpOnly"
        ]
      end
    end
  end
end
