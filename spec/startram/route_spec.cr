require "../spec_helper"

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

    describe "#path" do
      it "raises error on argument mismatch" do
        route = Route.new("/nested/:foo/:bar") { |request| Response.new }

        message = %(Expected arguments for :foo, :bar, got: {"one"})

        expect_raises ArgumentError, message do
          route.path("one")
        end
      end
    end
  end
end
