require "./spec_helper"

module Startram
  describe Request do
    describe "#params" do
      it "contains body and query params" do
        request = build_request("GET", "/?name=Amethyst&page=90",
          body: "user=Andrew&id=5",
          headers: HTTP::Headers{"Content-type": "application/x-www-form-urlencoded"}
        )

        request.params.should eq Hash{
          "user" => "Andrew"
          "id" => "5"
          "name" => "Amethyst"
          "page" => "90"
        }
      end
    end
  end

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

    describe "#write" do
      response = Response.new body: "lol"
      response.write "qwer"

      it "appends text to the body" do
        response.body.should eq "lolqwer"
      end

      it "sets the content length" do
        response.headers["Content-Length"].should eq "7"
      end
    end
  end
end
