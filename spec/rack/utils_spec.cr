require "../spec_helper"
require "../../src/rack/utils"

module Rack
  describe Utils do
    describe "#parse_query" do
      it "parses query strings correctly" do
        Utils.parse_query("foo=bar").should eq({ "foo" => "bar" })
        Utils.parse_query("foo=\"bar\"").should eq({ "foo" => "\"bar\"" })
        Utils.parse_query("foo=bar&foo=quux").should eq({ "foo" => ["bar", "quux"] })
        Utils.parse_query("foo=1&bar=2").should eq({ "foo" => "1", "bar" => "2" })
        Utils.parse_query("my+weird+field=q1%212%22%27w%245%267%2Fz8%29%3F").should eq({
          "my weird field" => "q1!2\"'w$5&7/z8)?"
        })
        Utils.parse_query("foo%3Dbaz=bar").should eq({ "foo=baz" => "bar" })
        Utils.parse_query("=").should eq({ "" => "" })
        Utils.parse_query("=value").should eq({ "" => "value" })
        Utils.parse_query("key=").should eq({ "key" => "" })
        Utils.parse_query("&key&").should eq({ "key" => "" }) # nil value in ruby
        Utils.parse_query(";key;", ";,").should eq({ "key" => "" }) # nil value in ruby
        Utils.parse_query(",key,", ";,").should eq({ "key" => "" }) # nil value in ruby
        Utils.parse_query(";foo=bar,;", ";,").should eq({ "foo" => "bar" })
        Utils.parse_query(",foo=bar;,", ";,").should eq({ "foo" => "bar" })
      end
    end

    describe "#parse_nested_query" do
      it "parses nested query strings correctly" do
        Utils.parse_nested_query("foo").should eq({ "foo" => "" }) # nil in ruby
        Utils.parse_nested_query("foo=").should eq({ "foo" => "" })
        Utils.parse_nested_query("foo=bar").should eq({ "foo" => "bar" })
        Utils.parse_nested_query("foo=\"bar\"").should eq({ "foo" => "\"bar\"" })

        Utils.parse_nested_query("foo=bar&foo=quux").should eq({ "foo" => "quux" })
        Utils.parse_nested_query("foo&foo=").should eq({ "foo" => "" })
        Utils.parse_nested_query("foo=1&bar=2").should eq({ "foo" => "1", "bar" => "2" })
        Utils.parse_nested_query("&foo=1&&bar=2").should eq({ "foo" => "1", "bar" => "2" })
        Utils.parse_nested_query("foo&bar=").should eq({ "foo" => nil, "bar" => "" })
        Utils.parse_nested_query("foo=bar&baz=").should eq({ "foo" => "bar", "baz" => "" })
        Utils.parse_nested_query("my+weird+field=q1%212%22%27w%245%267%2Fz8%29%3F").should eq({
          "my weird field" => "q1!2\"'w$5&7/z8)?"
        })

        Utils.parse_nested_query("a=b&pid%3D1234=1023").should eq({ "pid=1234" => "1023", "a" => "b" })

        Utils.parse_nested_query("foo[]").should eq({ "foo" => [nil] })
        Utils.parse_nested_query("foo[]=").should eq({ "foo" => [""] })
        Utils.parse_nested_query("foo[]=bar").should eq({ "foo" => ["bar"] })
        Utils.parse_nested_query("foo[]=bar&foo").should eq({ "foo" => nil })
        Utils.parse_nested_query("foo[]=bar&foo[").should eq({ "foo" => ["bar"], "foo[" => nil })
        Utils.parse_nested_query("foo[]=bar&foo[=baz").should eq({ "foo" => ["bar"], "foo[" => "baz" })
        Utils.parse_nested_query("foo[]=bar&foo[]").should eq({ "foo" => ["bar", nil] })
        Utils.parse_nested_query("foo[]=bar&foo[]=").should eq({ "foo" => ["bar", ""] })

        Utils.parse_nested_query("foo[]=1&foo[]=2").should eq({ "foo" => ["1", "2"] })
        Utils.parse_nested_query("foo=bar&baz[]=1&baz[]=2&baz[]=3").should eq({
          "foo" => "bar", "baz" => ["1", "2", "3"]
        })
        Utils.parse_nested_query("foo[]=bar&baz[]=1&baz[]=2&baz[]=3").should eq({
          "foo" => ["bar"], "baz" => ["1", "2", "3"]
        })

        Utils.parse_nested_query("x[y][z]=1").should eq({ "x" => {"y" => {"z" => "1"}} })
        Utils.parse_nested_query("x[y][z][]=1").should eq({ "x" => {"y" => {"z" => ["1"]}} })
        Utils.parse_nested_query("x[y][z]=1&x[y][z]=2").should eq({ "x" => {"y" => {"z" => "2"}} })
        Utils.parse_nested_query("x[y][z][]=1&x[y][z][]=2").should eq({ "x" => {"y" => {"z" => ["1", "2"]}} })

        Utils.parse_nested_query("x[y][][z]=1").should eq({ "x" => {"y" => [{"z" => "1"}]} })
        Utils.parse_nested_query("x[y][][z][]=1").should eq({ "x" => {"y" => [{"z" => ["1"]}]} })
        Utils.parse_nested_query("x[y][][z]=1&x[y][][w]=2").should eq({ "x" => {"y" => [{"z" => "1", "w" => "2"}]} })

        Utils.parse_nested_query("x[y][][v][w]=1").should eq({ "x" => {"y" => [{"v" => {"w" => "1"}}]} })
        Utils.parse_nested_query("x[y][][z]=1&x[y][][v][w]=2").should eq({ "x" => {"y" => [{"z" => "1", "v" => {"w" => "2"}}]} })

        Utils.parse_nested_query("x[y][][z]=1&x[y][][z]=2").should eq({ "x" => {"y" => [{"z" => "1"}, {"z" => "2"}]} })
        Utils.parse_nested_query("x[y][][z]=1&x[y][][w]=a&x[y][][z]=2&x[y][][w]=3").should eq({ "x" => {"y" => [{"z" => "1", "w" => "a"}, {"z" => "2", "w" => "3"}]} })
      end
    end

    describe "#unescape" do
      it "escapes strings" do
        Utils.unescape("fo%3Co%3Ebar").should eq "fo<o>bar"
        Utils.unescape("a+space").should eq "a space"
        Utils.unescape("a%20space").should eq "a space"
        Utils.unescape("q1%212%22%27w%245%267%2Fz8%29%3F%5C").should eq "q1!2\"'w$5&7/z8)?\\"
      end
    end
  end
end
