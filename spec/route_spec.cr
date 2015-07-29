require "./spec_helper"

module Startram
  describe Route do
    describe "#match?" do
      it "can have named parameters" do
        route = Route.new("/users/:name/invite") { |request| Response.new }

        route.match?("/users/david/invite").should be_truthy
        route.match?("/users/david/invite?foo=bar").should be_truthy
        route.match?("/users/david/invite/").should be_falsey
      end
    end
  end
end
