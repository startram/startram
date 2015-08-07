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

    describe "#set_cookie" do
      it "sets cookies" do
        response = Startram::Response.new

        response.set_cookie "foo", "bar"
        response.headers.get("Set-Cookie").should eq ["foo=bar"]
        response.set_cookie "foo2", "bar2"
        response.headers.get("Set-Cookie").should eq ["foo=bar", "foo2=bar2"]
        response.set_cookie "foo3", "bar3"
        response.headers.get("Set-Cookie").should eq ["foo=bar", "foo2=bar2", "foo3=bar3"]
      end

      it "can set cookies with the same name for multiple domains" do
        response = Startram::Response.new

        response.set_cookie "foo", "bar", domain: "sample.example.com"
        response.set_cookie "foo", "bar", domain: ".example.com"

        response.headers.get("Set-Cookie").should eq ["foo=bar; domain=sample.example.com", "foo=bar; domain=.example.com"]
      end

      it "formats the Cookie expiration date accordingly to RFC 6265" do
        response = Startram::Response.new

        response.set_cookie "foo", "bar", expires: 10.seconds.from_now

        response["Set-Cookie"].should match /expires=..., \d\d ... \d\d\d\d \d\d:\d\d:\d\d .../
      end

      it "can set secure cookies" do
        response = Startram::Response.new

        response.set_cookie "foo", "bar", secure: true

        response["Set-Cookie"].should eq "foo=bar; secure"
      end

      it "can set http only cookies" do
        response = Startram::Response.new

        response.set_cookie "foo", "bar", httponly: true

        response["Set-Cookie"].should eq "foo=bar; HttpOnly"
      end
    end

    describe "#expire_cookie" do
      it "can delete cookies" do
        response = Startram::Response.new

        response.set_cookie "foo", "bar"
        response.set_cookie "foo2", "bar2"

        response.expire_cookie "foo"

        response.headers.get("Set-Cookie").should eq [
          "foo2=bar2"
          "foo=; max-age=0; expires=Thu, 01 Jan 1970 00:00:00 -0000"
        ]
      end

      it "can expires cookies with the same name from multiple domains" do
        response = Startram::Response.new

        response.set_cookie "foo", "bar", domain: "sample.example.com"
        response.set_cookie "foo", "bar", domain: ".example.com"
        response.headers.get("Set-Cookie").should eq ["foo=bar; domain=sample.example.com", "foo=bar; domain=.example.com"]
        response.expire_cookie "foo", domain: ".example.com"
        response.headers.get("Set-Cookie").should eq ["foo=bar; domain=sample.example.com", "foo=; domain=.example.com; max-age=0; expires=Thu, 01 Jan 1970 00:00:00 -0000"]
        response.expire_cookie "foo", domain: "sample.example.com"
        response.headers.get("Set-Cookie").should eq ["foo=; domain=.example.com; max-age=0; expires=Thu, 01 Jan 1970 00:00:00 -0000",
                                             "foo=; domain=sample.example.com; max-age=0; expires=Thu, 01 Jan 1970 00:00:00 -0000"]

      end

      it "can expires cookies with the same name with different paths" do
        response = Startram::Response.new

        response.set_cookie "foo", "bar", path: "/"
        response.set_cookie "foo", "bar", path: "/path"
        response.headers.get("Set-Cookie").should eq ["foo=bar; path=/",
                                             "foo=bar; path=/path"]

        response.expire_cookie "foo", path: "/path"
        response.headers.get("Set-Cookie").should eq ["foo=bar; path=/",
                                             "foo=; path=/path; max-age=0; expires=Thu, 01 Jan 1970 00:00:00 -0000"]
      end
    end
  end
end
