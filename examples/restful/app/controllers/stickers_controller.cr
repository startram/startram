require "html/builder"

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
    view :new
  end

  def edit
    @sticker = Sticker.find(params["id"])

    view :edit
  end

  def create
    sticker = Sticker.new(params["title"])

    sticker.save

    redirect_to "/stickers"
  end

  def update
    sticker = Sticker.find(params["id"])

    sticker.title = params["title"]

    redirect_to "/stickers"
  end

  def destroy
    Sticker.destroy(params["id"])

    redirect_to "/stickers"
  end
end
