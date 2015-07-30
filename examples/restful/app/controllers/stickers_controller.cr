require "html/builder"

class StickersController < Startram::Controller
  def index
    stickers = Sticker.all

    body = HTML::Builder.new.build do
      h1 { text "Stickers" }
      ul do
        stickers.each do |sticker|
          li do
            a({href: "/stickers/#{sticker.id}"}) { text sticker.title }
            text " | "
            a({href: "/stickers/#{sticker.id}/edit"}) { text "edit" }
            text " | "
            a({href: "/stickers/#{sticker.id}?_method=DELETE"}) { text "destroy" }
          end
        end
      end
      a({href: "/stickers/new"}) { text "New Sticker" }
    end

    render body: body
  end

  def show
    sticker = Sticker.find(params["id"])

    render body: HTML::Builder.new.build do
      h1 { text sticker.title }
      a({href: "/stickers"}) { text "Back to list" }
    end
  end

  def new
    render body: HTML::Builder.new.build do
      h1 { text "New Sticker" }
      form({method: "POST", action: "/stickers"}) do
        input({type: "text", name: "title", placeholder: "Title"})
        input({type: "submit", value: "Submit"})
      end
      a({href: "/stickers"}) { text "Back to list" }
    end
  end

  def edit
    sticker = Sticker.find(params["id"])

    render body: HTML::Builder.new.build do
      h1 { text "Edit #{sticker.title}" }
      form({method: "POST", action: "/stickers/#{sticker.id}"}) do
        input({type: "hidden", name: "_method", value: "PUT"})
        input({type: "text", name: "title", placeholder: "Title", value: sticker.title})
        input({type: "submit", value: "Submit"})
      end
      a({href: "/stickers"}) { text "Back to list" }
    end
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
