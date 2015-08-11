require "../../spec_helper"

module Startram
  class Session
    describe Encoder do
      encoder = Encoder.new("ew234kjc6b213134b07509e19c49c53374f7fcf478cb25cdaa6b479f2eb1259b8df7858d4")
      session_string = "lol=qwer&hello=what"
      digested_string = "lol=qwer&hello=what--e93d7d09e284bd56e8f42a1353d51ff34017040c"

      describe "#encode" do
        it "encodes the string" do
          encoder.encode(session_string).should eq digested_string
        end
      end

      describe "#decode" do
        it "decodes the secret" do
          encoder.decode(digested_string).should eq session_string
        end

        it "returns empty string on invalid session" do
          encoder.decode("session_string").should eq ""
        end
      end
    end
  end
end
