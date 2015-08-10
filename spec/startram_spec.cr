require "./spec_helper"

class CarpetsController < Startram::Controller
  def index
    redirect_to edit_carpet_path("23")
  end
end

class TestApp < Startram::App
  routes do
    get "/test" do |context|
      response = context.response

      response.status = 200
      response.body = "Lol"
    end

    resources :carpets
  end
end

class TestApp2 < Startram::App
  routes do
    get "/test" do |context|
      response = context.response

      response.status = 201
    end
  end
end

app = TestApp.new
app2 = TestApp2.new

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
      end

      # Testing multi app to make sure the class based routes don't collide
      context "with a second app" do
        it "works too" do
          request = HTTP::Request.new("GET", "/test")

          response = app2.call(request)

          response.status_code.should eq 201
        end
      end
    end
  end
end
