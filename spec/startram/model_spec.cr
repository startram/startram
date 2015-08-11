require "../spec_helper"

class TestModel
  include Startram::Model

  field :id, Int32
  field :name, String
  field :age, Int32
  field :height, Float64
  field :poked_at, Time, default: -> { Time.at(108) }
  field :happy, Bool, default: true
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

      it "casts float" do
        model.height = "23.4"

        model.height.should eq 23.4
      end

      describe "default argument" do
        it "gets used as default value" do
          TestModel.new.happy.should be_true
        end

        it "runs a lambda" do
          TestModel.new.poked_at.should eq Time.at(108)
        end

        it "gets overridden by nil" do
          model = TestModel.new({"happy" => nil, "poked_at" => nil})

          model.happy.should be_nil
          model.poked_at.should be_nil
        end

        it "boolean default true gets overridden by false" do
          model = TestModel.new({"happy" => false})

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
      it "returns the model fields and data" do
        model.fields.keys.should eq([:id, :name, :age, :height, :poked_at, :happy])
        model.fields.values.first.type.should eq :Int32
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
