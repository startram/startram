class StickersController < Startram::Controller
  def index
    @stickers = Sticker.all

    view :index
  end

  def show
    @sticker = Sticker.find(params["id"])

    view :show
  end

  def new
    @sticker = Sticker.new()

    view :new
  end

  def edit
    @sticker = Sticker.find(params["id"])

    view :edit
  end

  def create
    sticker = Sticker.new(sticker_params)

    sticker.save

    redirect_to stickers_path
  end

  def update
    sticker = Sticker.find(params["id"])

    sticker.assign_attributes(sticker_params)

    redirect_to sticker_path(params["id"])
  end

  def destroy
    Sticker.destroy(params["id"])

    redirect_to stickers_path
  end

  private def sticker_params
    params["sticker"] as Hash(String, Rack::Utils::NestedParams)
  end
end
