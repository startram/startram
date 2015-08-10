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
    describe "#[]=" do
      it "sets values to @next which won't be reached in current request" do
        flash = Flash.new

        flash["foo"] = "bar"

        flash["foo"]?.should be_nil
        flash.@next["foo"].should eq "bar"
      end
    end

    describe "#now" do
      it "set values reachable in current request" do
        flash = Flash.new

        flash.now["foo"] = "bar"

        flash["foo"].should eq "bar"
      end
    end

    context "integrated in request lifecycle" do
      it "uses the previous session in render pipeline" do
        request = HTTP::Request.new(
          "PUT", "/session", HTTP::Headers{"Cookie" => "_startram_session=flash.notice%3DThis"}
        )

      end
    end
  end
end
