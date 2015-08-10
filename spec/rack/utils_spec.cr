require "../spec_helper"
require "../../src/rack/utils"

module Rack
  module Utils
    describe ".build_query" do
      it "builds query strings correctly" do
        build_query({"foo" => "bar"}).should eq "foo=bar"
        build_query({"foo" => "1", "bar" => "2"}).should eq "foo=1&bar=2"
        build_query({"foo" => ["bar", "quux"]}).should eq "foo=bar&foo=quux"
        build_query({"my weird field" => "q1!2\"'w$5&7/z8)?"}).should eq(
          "my+weird+field=q1%212%22%27w%245%267%2Fz8%29%3F"
        )
      end

      it "build query strings without = with non-existent values" do
        key = "post/2011/08/27/Deux-%22rat%C3%A9s%22-de-l-Universit"
        key = Rack::Utils.unescape(key)
        build_query({key => nil}).should eq Rack::Utils.escape(key)
      end
    end

    describe ".parse_query" do
      it "parses query strings correctly" do
        parse_query("foo=bar").should eq({ "foo" => "bar" })
        parse_query("foo=\"bar\"").should eq({ "foo" => "\"bar\"" })
        parse_query("foo=bar&foo=quux").should eq({ "foo" => ["bar", "quux"] })
        parse_query("foo=1&bar=2").should eq({ "foo" => "1", "bar" => "2" })
        parse_query("my+weird+field=q1%212%22%27w%245%267%2Fz8%29%3F").should eq({
          "my weird field" => "q1!2\"'w$5&7/z8)?"
        })
        parse_query("foo%3Dbaz=bar").should eq({ "foo=baz" => "bar" })
        parse_query("=").should eq({ "" => "" })
        parse_query("=value").should eq({ "" => "value" })
        parse_query("key=").should eq({ "key" => "" })
        parse_query("&key&").should eq({ "key" => "" }) # nil value in ruby
        parse_query(";key;", ";,").should eq({ "key" => "" }) # nil value in ruby
        parse_query(",key,", ";,").should eq({ "key" => "" }) # nil value in ruby
        parse_query(";foo=bar,;", ";,").should eq({ "foo" => "bar" })
        parse_query(",foo=bar;,", ";,").should eq({ "foo" => "bar" })
      end
    end

    describe ".parse_nested_query" do
      it "parses shallow strings" do
        parse_nested_query("foo").should eq({ "foo" => "" }) # nil in ruby
        parse_nested_query("foo=").should eq({ "foo" => "" })
        parse_nested_query("foo=bar").should eq({ "foo" => "bar" })
        parse_nested_query("foo=\"bar\"").should eq({ "foo" => "\"bar\"" })

        parse_nested_query("foo=bar&foo=quux").should eq({ "foo" => "quux" })
        parse_nested_query("foo&foo=").should eq({ "foo" => "" })
        parse_nested_query("foo=1&bar=2").should eq({ "foo" => "1", "bar" => "2" })
        parse_nested_query("&foo=1&&bar=2").should eq({ "foo" => "1", "bar" => "2" })
        parse_nested_query("foo&bar=").should eq({ "foo" => "", "bar" => "" }) # foo => nil in ruby
        parse_nested_query("foo=bar&baz=").should eq({ "foo" => "bar", "baz" => "" })
        parse_nested_query("my+weird+field=q1%212%22%27w%245%267%2Fz8%29%3F").should eq({
          "my weird field" => "q1!2\"'w$5&7/z8)?"
        })

        parse_nested_query("a=b&pid%3D1234=1023").should eq({ "pid=1234" => "1023", "a" => "b" })
      end

      it "parses shallow arrays" do
        parse_nested_query("foo[]").should eq({ "foo" => [""] }) # [nil] in ruby
        parse_nested_query("foo[]=").should eq({ "foo" => [""] })
        parse_nested_query("foo[]=bar").should eq({ "foo" => ["bar"] })
        parse_nested_query("foo[]=bar&foo").should eq({ "foo" => "" }) # nil in ruby
        parse_nested_query("foo[]=bar&foo[").should eq({ "foo" => ["bar"], "foo[" => "" }) # foo[ => nil in ruby
        parse_nested_query("foo[]=bar&foo[=baz").should eq({ "foo" => ["bar"], "foo[" => "baz" })
        parse_nested_query("foo[]=bar&foo[]").should eq({ "foo" => ["bar", ""] }) # "bar", nil in ruby
        parse_nested_query("foo[]=bar&foo[]=").should eq({ "foo" => ["bar", ""] })

        parse_nested_query("foo[]=1&foo[]=2").should eq({ "foo" => ["1", "2"] })
        parse_nested_query("foo=bar&baz[]=1&baz[]=2&baz[]=3").should eq({
          "foo" => "bar", "baz" => ["1", "2", "3"]
        })
        parse_nested_query("foo[]=bar&baz[]=1&baz[]=2&baz[]=3").should eq({
          "foo" => ["bar"], "baz" => ["1", "2", "3"]
        })
      end

      it "parses nested queries" do
        parse_nested_query("x[y]=1").should eq({ "x" => {"y" => "1"} })
        parse_nested_query("x[y][z]=1").should eq({ "x" => {"y" => {"z" => "1"}} })
        parse_nested_query("x[y][z][]=1").should eq({ "x" => {"y" => {"z" => ["1"]}} })
        parse_nested_query("x[y][z]=1&x[y][z]=2").should eq({ "x" => {"y" => {"z" => "2"}} })
        parse_nested_query("x[y][z][]=1&x[y][z][]=2").should eq({ "x" => {"y" => {"z" => ["1", "2"]}} })

        parse_nested_query("x[y][][z]=1").should eq({ "x" => {"y" => [{"z" => "1"}]} })
        parse_nested_query("x[y][][z][]=1").should eq({ "x" => {"y" => [{"z" => ["1"]}]} })
        parse_nested_query("x[y][][z]=1&x[y][][w]=2").should eq({ "x" => {"y" => [{"z" => "1", "w" => "2"}]} })

        parse_nested_query("x[y][][v][w]=1").should eq({ "x" => {"y" => [{"v" => {"w" => "1"}}]} })
        parse_nested_query("x[y][][z]=1&x[y][][v][w]=2").should eq({ "x" => {"y" => [{"z" => "1", "v" => {"w" => "2"}}]} })

        parse_nested_query("x[y][][z]=1&x[y][][z]=2").should eq({ "x" => {"y" => [{"z" => "1"}, {"z" => "2"}]} })
        parse_nested_query("x[y][][z]=1&x[y][][w]=a&x[y][][z]=2&x[y][][w]=3").should eq({ "x" => {"y" => [{"z" => "1", "w" => "a"}, {"z" => "2", "w" => "3"}]} })
      end

      it "raises errors on format inconsistencies" do
        expect_raises ParameterTypeError, "expected Hash (got String) for param `y'" do
          parse_nested_query("x[y]=1&x[y]z=2")
        end

        expect_raises ParameterTypeError, /expected Array \(got .*\) for param `x'/ do
          parse_nested_query("x[y]=1&x[]=1")
        end

        expect_raises ParameterTypeError, "expected Array (got String) for param `y'" do
          parse_nested_query("x[y]=1&x[y][][w]=2")
        end
      end
    end

    describe ".parse_cookies" do
      it "parses cookies" do
        headers = {"Cookie" => "zoo=m"}
        parse_cookies(headers).should eq({"zoo" => "m"})

        headers = {"Cookie" => "foo=%"}
        parse_cookies(headers).should eq({"foo" => "%"})

        headers = {"Cookie" => "foo=bar;foo=car"}
        parse_cookies(headers).should eq({"foo" => "bar"})

        headers = {"Cookie" => "foo=bar;quux=h&m"}
        parse_cookies(headers).should eq({"foo" => "bar", "quux" => "h&m"})

        headers = {"Cookie" => "foo=bar"}
        parse_cookies(headers).should eq({"foo" => "bar"})
      end
    end

    describe ".unescape" do
      it "escapes strings" do
        unescape("fo%3Co%3Ebar").should eq "fo<o>bar"
        unescape("a+space").should eq "a space"
        unescape("a%20space").should eq "a space"
        unescape("q1%212%22%27w%245%267%2Fz8%29%3F%5C").should eq "q1!2\"'w$5&7/z8)?\\"
      end
    end
  end
end
