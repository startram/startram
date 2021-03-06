require "../spec_helper"

class SessionController < Startram::Controller
  def create
    session["user_id"] = "23"
    session["flash"] = "hello!"
  end

  def show
    render body: session["user_id"]
  end
end

class SessionTestApp < Startram::App
  routes do
    post "/session", SessionController, :create
    get "/session", SessionController, :show
  end

  configure({
    "session_key" => "_my_test_session"
    "secret_key_base" => "ew234kjc6b213134b07509e19c49c53374f7fcf478cb25cdaa6b479f2eb1259b8df7858d4"
  })
end

app = SessionTestApp.new

module Startram
  describe Session do
    describe "#deserialize!" do
      session = Session.new

      session.deserialize! "user_id=23&foo=bar"

      session["user_id"].should eq "23"
      session["foo"].should eq "bar"
    end

    describe "#serialize" do
      session = Session.new

      session["foo"] = "bar"
      session["asdf"] = "qwer"

      session.serialize.should eq "foo=bar&asdf=qwer"
    end

    context "integrated in the request lifecycle" do
      it "sets a session cookie" do
        request = HTTP::Request.new("POST", "/session")

        response = app.call(request)

        response.headers.get("Set-Cookie").should eq [
          "_my_test_session=user_id%3D23%26flash%3Dhello%21--cd3d95db554fcc3474204bc7af800ba742dbfad8; path=/; HttpOnly"
        ]
      end

      it "reads a session cookie" do
        request = HTTP::Request.new("GET", "/session", HTTP::Headers{
          "Cookie" => "_my_test_session=user_id%3D23--8f3848fefb2ec3a70ea9d554f1694997b1b0d738"
        })

        response = app.call(request)

        response.body.should eq "23"
      end
    end
  end
end
