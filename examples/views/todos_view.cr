require "ecr/macros"

class TodosView
  ecr_file "#{__DIR__}/todos.ecr"

  def initialize(@tasks)
  end

  def cats_are_awesome(text)
    "#{text} cats are awesome!"
  end
end
