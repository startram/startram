require "ecr/macros"

class TodosView
  ecr_file "#{__DIR__}/todos.ecr"

  def initialize(@tasks)
  end
end
