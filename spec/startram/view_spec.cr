require "../spec_helper"

require "ecr/macros"

class TestView < Startram::View
  ecr_file "#{__DIR__}/views/test.ecr"
end

class TestController < Startram::Controller
  def test
    @title = "Yolo"
    render body: TestView.new(self)
  end
end

class ViewTestApp < Startram::App
  routes do
    get "/test/:foo", TestController, :test, name: "test"
  end
end

app = ViewTestApp.new

module Startram
  describe View do
    it "renders ok" do
      request = HTTP::Request.new("GET", "/test/bar")

      response = app.call(request)

      response.body.should eq %(Yolo\n/test/bar\n)
    end
  end
end
