require "./spec_helper"

class CarpetsController < Startram::Controller
  def index
    redirect_to edit_carpet_path("23")
  end
end

class ApplesController < Startram::Controller

end

class TestApp < Startram::App
  router.draw do
    get "/test" do |context|
      response = context.response

      response.status = 200
      response.body = "Lol"
    end

    resources :carpets
  end
end

class LolApp < Startram::App
  router.draw do
    get "/lol" do |context|
      response = context.response

      response.status = 201
      response.body = "Lol :D"
    end

    resources :apples
  end

end

app = TestApp.new
app2 = LolApp.new

module Startram
  describe App do
    describe "#call" do
      context "to a proc route" do
        it "should work out" do
          request = HTTP::Request.new("GET", "/test")

          response = app.call(request)

          response.status_code.should eq 200
          response.body.should eq "Lol"
        end
      end

      context "to a resource route" do
        it "should work out" do
          request = HTTP::Request.new("GET", "/carpets")

          response = app.call(request)

          response.status_code.should eq 302
          response.headers["Location"].should eq "/carpets/23/edit"
        end

        it "works with apples to" do
          request = HTTP::Request.new("GET", "/apples")

          response = app2.call(request)

          response.status_code.should eq 302
          response.headers["Location"].should eq "/carpets/23/edit"
        end
      end
    end
  end
end
