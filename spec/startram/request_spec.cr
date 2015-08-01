require "../spec_helper"

module Startram
  describe Request do
    describe "#params" do
      it "contains body and query params" do
        request = build_request("GET", "/?name=Amethyst&page=90",
          body: "user=Andrew&id=5&person[age]=32",
          headers: HTTP::Headers{"Content-type": "application/x-www-form-urlencoded"}
        )

        request.params.should eq Hash{
          "user" => "Andrew"
          "id" => "5"
          "name" => "Amethyst"
          "page" => "90"
          "person" => {
            "age" => "32"
          }
        }
      end
    end
  end
end
