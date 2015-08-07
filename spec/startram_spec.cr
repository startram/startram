require "./spec_helper"

class CarpetsController < Startram::Controller
  def index
    redirect_to edit_carpet_path("23")
  end
end

app = Startram::App.new

app.router.draw do
  get "/test" do |context|
    response = context.response

    response.status = 200
    response.body = "Lol"
  end

  resources :carpets
end

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
    end
  end
end
