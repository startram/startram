class Task
  def self.all
    [
      Task.new("Make it rain!")
      Task.new("Snow is kinda cold!")
      Task.new("Snow is frozen")
    ]
  end

  property :name

  def initialize(@name)
  end

  json_mapping({
    "name" => String
  })
end
