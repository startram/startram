module Startram
  module Model
    alias Attributes = Hash(String, String | Int32 | Int64 | Nil | Time | Bool)

    macro included
      @@fields = {} of Symbol => Symbol

      def initialize(attributes = Attributes.new)
        @attributes = Attributes.new
        @persisted = false

        assign_attributes(attributes)
      end
    end

    macro field(name, type = String)
      @@fields[{{name}}] = :{{type}}

      def {{name.id}}
        attributes[{{name.id.stringify}}]? as {{type}}?
      end

      def {{name.id}}=(value)
        attributes[{{name.id.stringify}}] = cast(value, :{{type}})
      end
    end

    def fields
      @@fields
    end

    def attributes
      @attributes ||= Attributes.new
    end

    def assign_attributes(attributes)
      fields.each do |name, type|
        attribute = name.to_s
        if attributes.has_key?(attribute)
          @attributes[attribute] = cast(attributes[attribute], type)
        end
      end
    end

    TRUTHY = %w[true t 1 1.0 yes y]

    private def cast(value, type)
      return nil if value.nil?

      case type
      when :String
        value.to_s
      when :Int32, :Int64
        value.to_s.to_i
      when :Time
        value.is_a?(Time) ? value : Time.parse(value.to_s, "%FT%X.%L%z")
      when :Bool
        TRUTHY.includes?(value.to_s)
      end
    end
  end
end
