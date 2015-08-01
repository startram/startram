require "../spec_helper"

module Startram
  describe Response do
    describe "[]=" do
      it "writes to headers" do
        response = Response.new

        response["Content-Type"] = "text/html"

        response.headers["Content-Type"].should eq "text/html"
      end
    end

    describe "[]" do
      it "reads from headers" do
        response = Response.new

        response.headers.add "Content-Type", "text/plain"

        response["Content-Type"].should eq "text/plain"
      end
    end
  end
end
