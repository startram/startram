require "../../spec_helper"

class HelperClass
  include Startram::View::Helpers
end

h = HelperClass.new

describe Startram::View::Helpers do
  describe "#asset_path" do
    context "with javascript format" do
      it "returns a javascript path" do
        h.asset_path("foo", :javascript).should eq "/javascripts/foo.js"
        h.asset_path("foo.js", :javascript).should eq "/javascripts/foo.js"
        h.asset_path("foo/bar", :javascript).should eq "/javascripts/foo/bar.js"
      end
    end

    context "with stylesheet format" do
      it "returns a stylesheet path" do
        h.asset_path("foo", :stylesheet).should eq "/stylesheets/foo.css"
        h.asset_path("foo.css", :stylesheet).should eq "/stylesheets/foo.css"
        h.asset_path("foo/bar", :stylesheet).should eq "/stylesheets/foo/bar.css"
      end
    end

    context "with image format" do
      it "returns an image path" do
        h.asset_path("foo", :image).should eq "/images/foo"
        h.asset_path("foo.png", :image).should eq "/images/foo.png"
        h.asset_path("foo/bar.jpg", :image).should eq "/images/foo/bar.jpg"
      end
    end
  end

  describe "#javascript_include_tag" do
    it "generates a script tag" do
      h.javascript_include_tag("application").should eq(
        %(<script src="/javascripts/application.js"></script>)
      )
    end

    it "with an array generates multiple script tags" do
      h.javascript_include_tag(%w[jquery application]).should eq(
        %(<script src="/javascripts/jquery.js"></script>) +
        %(<script src="/javascripts/application.js"></script>)
      )
    end
  end

  describe "#stylesheet_link_tag" do
    it "generates a link tag" do
      h.stylesheet_link_tag("application").should eq(
        %(<link rel="stylesheet" media="all" href="/stylesheets/application.css">)
      )
    end

    it "with an array generates multiple link tags" do
      h.stylesheet_link_tag(%w[bootstrap application]).should eq(
        %(<link rel="stylesheet" media="all" href="/stylesheets/bootstrap.css">) +
        %(<link rel="stylesheet" media="all" href="/stylesheets/application.css">)
      )
    end
  end

  describe "#image_tag" do
    it "generates an img tag" do
      h.image_tag("lolcat.gif").should eq %(<img src="/images/lolcat.gif">)
    end
  end
end
