class TodosController < Startram::Controller
  def index
    tasks = Task.all

    if accept.to_s.includes?("json")
      render body: tasks.to_json, content_type: "application/json"
    else
      render body: TodosView.new(tasks).to_s
    end
  end

  def show
    render body: "Show: #{params}"
  end
end
