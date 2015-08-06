require "../spec_helper"

module Startram
  describe Router do
    handler = -> (request : Request) { Response.new }

    it "adds route helpers" do
      router = Router.new

      router.draw do
        get "/awesome", &handler
        get "/foo", name: "bar", &handler
        get "/users/:id", name: "user", &handler
        get "/deeply/:id/nested/:dynamic/:params", name: "deep", &handler
      end

      router.url_helpers.awesome_path.should eq "/awesome"
      router.url_helpers.bar_path.should eq "/foo"
      router.url_helpers.user_path("23").should eq "/users/23"
      router.url_helpers.deep_path("23", "foo", "bar").should eq "/deeply/23/nested/foo/bar"
    end
  end
end
