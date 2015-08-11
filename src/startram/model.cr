module Startram
  module Model
    alias Values = String | Int32 | Int64 | Float32 | Float64 | Nil | Time | Bool
    alias Attributes = Hash(String, Values)

    class FieldData
      getter name, type

      def initialize(@name, @type, default = nil)
        unless default.nil?
          @default = default.is_a?(Proc) ? default : -> { default as Values }
        end
      end

      def default
        if @default
          (@default as Proc).call
        end
      end
    end

    macro included
      @@fields = {} of Symbol => FieldData

      def initialize(attributes = Attributes.new)
        @attributes = Attributes.new
        @persisted = false

        assign_attributes(attributes)
        set_default_values
      end
    end

    macro field(name, type, default = nil)
      @@fields[{{name}}] = FieldData.new({{name.id.stringify}}, :{{type}}, {{default}})

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
      fields.each do |name, data|
        if attributes.has_key?(data.name)
          @attributes[data.name] = cast(attributes[data.name], data.type)
        end
      end
    end

    private def set_default_values
      fields.each do |name, data|
        unless attributes.has_key?(data.name)
          attributes[data.name] = data.default if data.default
        end
      end
    end

    TRUTHY = %w[true t 1 1.0 yes y]

    private def cast(value, type)
      return nil if value.nil?

      case type
      when :String
        value.to_s
      when :Int32
        value.to_s.to_i32
      when :Int64
        value.to_s.to_i64
      when :Time
        value.is_a?(Time) ? value : Time.parse(value.to_s, "%FT%X.%L%z")
      when :Bool
        TRUTHY.includes?(value.to_s)
      when :Float32
        value.to_s.to_f32
      when :Float64
        value.to_s.to_f64
      end
    end
  end
end
