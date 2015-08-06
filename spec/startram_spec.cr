require "./spec_helper"

class CarpetsController < Startram::Controller
  def index
    redirect_to new_carpet_path
  end
end

app = Startram::App.new

app.router.draw do
  get "/test" do |context|
    Startram::Response.new 200, "Lol"
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
          response.headers["Location"].should eq "/carpets/new"
        end
      end
    end
  end
end
