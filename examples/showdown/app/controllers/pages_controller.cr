class PagesController < Startram::Controller
  layout :application

  def index
    @title = params["title"].to_s

    @members = [
      { name: "Chris McCord" }
      { name: "Matt Sears" }
      { name: "David Stump" }
      { name: "Ricardo Thompson" }
    ]

    view :index
  end
end
