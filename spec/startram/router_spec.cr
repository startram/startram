require "../spec_helper"

class CookiesController < Startram::Controller
end

module Startram
  describe Router do
    handler = -> (con : Context) { Response.new }

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

    describe "#resources" do
      it "adds restful routes" do
        router = Router.new

        router.draw do
          resources :cookies
        end

        router.url_helpers.cookies_path.should eq "/cookies"
        router.url_helpers.cooky_path("42").should eq "/cookies/42"
        router.url_helpers.edit_cooky_path("108").should eq "/cookies/108/edit"
        router.url_helpers.new_cooky_path.should eq "/cookies/new"
      end
    end
  end
end
