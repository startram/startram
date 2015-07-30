class WeatherController < Startram::Controller
  def status
    render body: "It is sunny with a slight chance of apocalypse!"
  end
end
