require "../spec_helper"

class TestModel
  include Startram::Model

  field :id, type: Int32
  field :name
  field :age, type: Int32
  field :poked_at, type: Time
  field :happy, type: Bool
end

module Startram
  describe Model do
    model = TestModel.new

    describe "field" do
      it "casts to string by default" do
        model.name = "foo"

        model.name.should eq "foo"
        model.attributes["name"].should eq "foo"
      end

      it "casts integer" do
        model.age = "23"

        model.age.should eq 23
        model.attributes["age"].should eq 23
      end

      it "casts ISO 8601 time" do
        model.poked_at = "2015-04-22T13:24:42.484Z"

        model.poked_at.should eq Time.parse("2015-04-22T13:24:42.484Z", "%FT%X.%L%z")

        model.poked_at = Time.at(123456789)

        model.poked_at.should eq Time.at(123456789)
      end

      it "casts boolean" do
        [true, "true", "t", "1", "1.0", "yes", "y"].each do |truthy|
          model.happy = truthy

          model.happy.should be_true
        end

        [false, "false", "f", "0", "0.0", "no", "n"].each do |falsy|
          model.happy = falsy

          model.happy.should be_false
        end
      end

      it "is nilable" do
        model.name = "foo"
        model.name = nil

        model.name.should be_nil
      end

      it "is setable via constructor" do
        model = TestModel.new({"name" => "foo", "age" => "23"})

        model.name.should eq "foo"
        model.age.should eq 23
      end
    end

    describe "#fields" do
      it "returns the model fields" do
        model.fields.should eq({
          :id => :Int32
          :name => :String
          :age => :Int32
          :poked_at => :Time
          :happy => :Bool
        })
      end
    end

    describe "#assign_attributes" do
      it "assigns the attributes" do
        model.assign_attributes({
          "name" => "foo"
          "age" => "23"
          "happy" => "t"
        })

        model.name.should eq "foo"
        model.age.should eq 23
        model.happy.should be_true
      end
    end
  end
end
